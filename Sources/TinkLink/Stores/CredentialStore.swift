import Foundation

final class CredentialStore {
    static let shared = CredentialStore()
    
    var credentials: [Identifier<Credential>: Credential] = [:] {
        didSet {
            NotificationCenter.default.post(name: .credentialStoreChanged, object: self)
        }
    }
    private var service: CredentialService
    private var createCredentialCanceller: [Identifier<Provider>: Cancellable] = [:]
    private var credentialStatusPollingCanceller: [Identifier<Credential>: Cancellable] = [:]
    private var addSupplementalInformationCanceller: [Identifier<Credential>: Cancellable] = [:]
    private var cancelSupplementInformationCanceller: [Identifier<Credential>: Cancellable] = [:]
    
    private init() {
        service = TinkLink.shared.client.credentialService
    }
    
    func addCredential(for provider: Provider, fields: [String: String], completion: @escaping(Result<Credential, Error>) -> Void) -> Cancellable {
        if let canceller = createCredentialCanceller[provider.name] {
            return canceller
        }
        let canceller = service.createCredential(providerName: provider.name, fields: fields, completion: { [weak self, provider] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let credential = try result.get()
                    completion(.success(credential))
                    self.credentials[credential.id] = credential
                    self.pollingStatus(for: credential)
                } catch let error {
                    completion(.failure(error))
                }
                self.createCredentialCanceller[provider.name] = nil
            }
        })
        createCredentialCanceller[provider.name] = canceller
        return canceller
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String]) {
        addSupplementalInformationCanceller[credential.id] = service.supplementInformation(credentialID: credential.id, fields: supplementalInformationFields) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    // error
                    break
                case .success:
                    // polling
                    self.pollingStatus(for: credential)
                }
            }
            self.addSupplementalInformationCanceller[credential.id] = nil
        }
    }
    
    func cancelSupplementInformation(for credential: Credential) {
        guard cancelSupplementInformationCanceller[credential.id] == nil else { return }
        cancelSupplementInformationCanceller[credential.id] = service.cancelSupplementInformation(credentialID: credential.id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    break
                case .success(let credential):
                    // polling
                    break
                }
                self.cancelSupplementInformationCanceller[credential.id] = nil
            }
        }
    }
    
    private func pollingStatus(for credential: Credential) {
        guard credentialStatusPollingCanceller[credential.id] == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.credentialStatusPollingCanceller[credential.id] = self.service.credentials { [weak self, credential] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.credentialStatusPollingCanceller[credential.id] = nil
                    do {
                        let credentials = try result.get()
                        if let updatedCredential = credentials.first(where: { $0.id == credential.id}) {
                            if updatedCredential.status == .updating {
                                self.credentials[credential.id] = updatedCredential
                                self.pollingStatus(for: updatedCredential)
                            } else if updatedCredential.status == .awaitingSupplementalInformation {
                                self.credentials[credential.id] = updatedCredential
                            } else if updatedCredential.status == credential.status {
                                self.pollingStatus(for: updatedCredential)
                            } else {
                                self.credentials[credential.id] = updatedCredential
                            }
                        } else {
                            fatalError("No such credential with " + credential.id.rawValue)
                        }
                    } catch let error {
                        print(error)
                    }
                }
            }
        })
    }
}

extension Notification.Name {
    static let credentialStoreChanged = Notification.Name("TinkLinkCredentialStoreChangedNotificationName")
}
