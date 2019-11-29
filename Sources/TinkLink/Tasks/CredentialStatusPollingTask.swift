import Foundation
import SwiftGRPC

class CredentialStatusPollingTask {
    private var service: CredentialService
    var callRetryCancellable: RetryCancellable?
    private var retryInterval: TimeInterval = 1
    private(set) var credential: Credential
    private var updateHandler: (Result<Credential, Error>) -> Void
    private let backoffStrategy: PollingBackoffStrategy

    enum PollingBackoffStrategy {
        case none
        case linear
        case exponential

        func nextInterval(for retryinterval: TimeInterval) -> TimeInterval {
            switch self {
            case .none:
                return retryinterval
            case .linear:
                return retryinterval + 1
            case .exponential:
                return retryinterval * 2
            }
        }
    }

    init(credentialService: CredentialService, credential: Credential, backoffStrategy: PollingBackoffStrategy = .linear, updateHandler: @escaping (Result<Credential, Error>) -> Void) {
        self.service = credentialService
        self.credential = credential
        self.backoffStrategy = backoffStrategy
        self.updateHandler = updateHandler
    }

    func pollStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
            self.callRetryCancellable = self.service.credentials { [weak self] result in
                guard let self = self else { return }
                do {
                    let credentials = try result.get()
                    if let updatedCredential = credentials.first(where: { $0.id == self.credential.id }) {
                        switch updatedCredential.status {
                        case .updated, .awaitingSupplementalInformation, .awaitingMobileBankIDAuthentication, .awaitingThirdPartyAppAuthentication:
                            self.updateHandler(.success(updatedCredential))
                            self.callRetryCancellable = nil
                        case .updating:
                            self.updateHandler(.success(updatedCredential))
                            self.retry()
                        case self.credential.status:
                            // TODO: Should not keep polling while receiving status error, but maybe should poll for the authenticationError of an old error that has not been updated?
                            self.retry()
                        default:
                            self.updateHandler(.success(updatedCredential))
                            self.callRetryCancellable = nil
                        }
                    } else {
                        fatalError("No such credential with " + self.credential.id.value)
                    }
                } catch {
                    self.updateHandler(.failure(error))
                }
            }
        }
    }

    private func retry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            self?.callRetryCancellable?.retry()
        }
        retryInterval = backoffStrategy.nextInterval(for: retryInterval)
    }
}
