import SwiftGRPC
import Foundation

class CredentialStatusPollingTask {
    private var service: CredentialService
    private var callRetryCancellable: RetryCancellable?
    private var retryInterval: TimeInterval = 1
    private(set) var credential: Credential
    private var updateHandler: (Result<Credential, Error>) -> Void
    let backoffStrategy: PollingBackoffStrategy
    
    enum PollingBackoffStrategy {
        case none
        case linear
        case exponential
        
        func nextInteral(for retryinterval: TimeInterval) -> TimeInterval {
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
    
    init(tinkLink: TinkLink = .shared, credential: Credential, backoffStrategy: PollingBackoffStrategy = .linear, updateHandler: @escaping (Result<Credential, Error>) -> Void) {
        self.service = tinkLink.client.credentialService
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
                    if let updatedCredential = credentials.first(where: { $0.id == self.credential.id}) {
                        if updatedCredential.status == .updating {
                            self.updateHandler(.success(updatedCredential))
                            self.retry()
                        } else if updatedCredential.status == .awaitingSupplementalInformation {
                            self.updateHandler(.success(updatedCredential))
                            self.callRetryCancellable = nil
                            // TODO: Should not keep polling while receiving status error 
                        } else if updatedCredential.status == self.credential.status {
                            self.retry()
                        } else {
                            self.updateHandler(.success(updatedCredential))
                            self.callRetryCancellable = nil
                        }
                    } else {
                        fatalError("No such credential with " + self.credential.id.rawValue)
                    }
                } catch let error {
                    self.updateHandler(.failure(error))
                }
            }
        }
    }
    
    private func retry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            self?.callRetryCancellable?.retry()
        }
        retryInterval = backoffStrategy.nextInteral(for: retryInterval)
    }
}
