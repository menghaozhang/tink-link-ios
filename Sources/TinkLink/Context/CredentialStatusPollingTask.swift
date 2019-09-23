import SwiftGRPC
import Foundation

class CredentialStatusPollingTask {
    private var service = TinkLink.shared.client.credentialService
    private var callHandler: Handleable?
    private var retryInterval: TimeInterval = 1
    private(set) var credential: Credential
    private var updateHandler: (Credential) -> Void
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
    
    init(credential: Credential, backoffStrategy: PollingBackoffStrategy = .linear, updateHandler: @escaping (Credential) -> Void) {
        self.credential = credential
        self.backoffStrategy = backoffStrategy
        self.updateHandler = updateHandler
    }
    
    func pollStatus() {
        self.callHandler = self.service.credentials { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let credentials = try result.get()
                    if let updatedCredential = credentials.first(where: { $0.id == self.credential.id}) {
                        if updatedCredential.status == .updating {
                            self.updateHandler(updatedCredential)
                            self.retry()
                        } else if updatedCredential.status == .awaitingSupplementalInformation {
                            self.updateHandler(updatedCredential)
                            self.callHandler = nil
                        } else if updatedCredential.status == self.credential.status {
                            self.retry()
                        } else {
                            self.updateHandler(updatedCredential)
                            self.callHandler = nil
                        }
                    } else {
                        fatalError("No such credential with " + self.credential.id.rawValue)
                    }
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    private func retry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            self?.callHandler?.retry()
        }
        retryInterval = backoffStrategy.nextInteral(for: retryInterval)
    }
}
