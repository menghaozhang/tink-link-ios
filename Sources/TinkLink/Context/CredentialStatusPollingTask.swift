import SwiftGRPC
import Foundation

class CredentialStatusPollingTask {
    private var service = TinkLink.shared.client.credentialService
    private let credentialStore = CredentialStore.shared
    private var callHandler: (Cancellable & Retriable)?
    private var retryInterval: TimeInterval = 1
    private(set) var credential: Credential
    
    init(credential: Credential) {
        self.credential = credential
    }
    
    func pollingStatus() {
        self.callHandler = self.service.credentials { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let credentials = try result.get()
                    if let updatedCredential = credentials.first(where: { $0.id == self.credential.id}) {
                        if updatedCredential.status == .updating {
                            self.credentialStore.credentials[self.credential.id] = updatedCredential
                            self.retry()
                        } else if updatedCredential.status == .awaitingSupplementalInformation {
                            self.credentialStore.credentials[self.credential.id] = updatedCredential
                            self.callHandler = nil
                        } else if updatedCredential.status == self.credential.status {
                            self.retry()
                        } else {
                            self.credentialStore.credentials[self.credential.id] = updatedCredential
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
        retryInterval *= 2
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            self?.callHandler?.retry()
        }
    }
}
