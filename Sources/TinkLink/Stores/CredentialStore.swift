import Foundation

class CredentialStore {
    static let shared = CredentialStore()
    
    var credentials: [Identifier<Credential>: Credential] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.credentialStoreObservers.forEach { (tokenID, handler) in
                    handler(tokenID)
                }
            }
        }
    }
    private var service: CredentialService
    private var createCredentialCallerCanceller: [Identifier<Provider>: Cancellable?] = [:]
    private var credentialStatusPollingCallerCanceller: [Identifier<Credential>: Cancellable?] = [:]
    private var addSupplementalInformationCallerCanceller: [Identifier<Credential>: Cancellable?] = [:]
    private var cancelSupplementInformationCallerCanceller: [Identifier<Credential>: Cancellable?] = [:]
    
    private init() {
        service = TinkLink.shared.client.credentialService
    }
    
    func addCredential(for provider: Provider, fields: [Provider.FieldSpecification], completion: @escaping(Result<Credential, Error>) -> Void) {
        guard createCredentialCallerCanceller[provider.name] == nil else {
            return
        }
        createCredentialCallerCanceller[provider.name] = service.createCredential(providerName: provider.name, fields: fields.makeFields(), completion: { [weak self, provider] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                do {
                    let credential = try result.get()
                    completion(.success(credential))
                    strongSelf.credentials[credential.id] = credential
                    strongSelf.pollingStatus(for: credential)
                } catch let error {
                    completion(.failure(error))
                }
                strongSelf.createCredentialCallerCanceller[provider.name] = nil
            }
        })
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [Provider.FieldSpecification]) {
        addSupplementalInformationCallerCanceller[credential.id] = service.supplementInformation(credentialID: credential.id, fields: supplementalInformationFields.makeFields()) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    // error
                    break
                case .success:
                    // polling
                    strongSelf.pollingStatus(for: credential)
                }
            }
            strongSelf.addSupplementalInformationCallerCanceller[credential.id] = nil
        }
    }
    
    func cancelSupplementInformation(for credential: Credential) {
        guard cancelSupplementInformationCallerCanceller[credential.id] == nil else { return }
        cancelSupplementInformationCallerCanceller[credential.id] = service.cancelSupplementInformation(credentialID: credential.id) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    break
                case .success(let credential):
                    // polling
                    break
                }
                strongSelf.cancelSupplementInformationCallerCanceller[credential.id] = nil
            }
        }
    }
    
    private func pollingStatus(for credential: Credential) {
        guard credentialStatusPollingCallerCanceller[credential.id] == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.credentialStatusPollingCallerCanceller[credential.id] = self.service.credentials { [weak self, credential] result in
                guard let strongSelf = self else { return }
                strongSelf.credentialStatusPollingCallerCanceller[credential.id] = nil
                do {
                    let credentials = try result.get()
                    if let updatedCredential = credentials.first(where: { $0.id == credential.id}) {
                        if updatedCredential.status == .updating {
                            strongSelf.credentials[credential.id] = updatedCredential
                            strongSelf.pollingStatus(for: updatedCredential)
                        } else if updatedCredential.status == .awaitingSupplementalInformation {
                            strongSelf.credentials[credential.id] = updatedCredential
                        } else if updatedCredential.status == credential.status {
                            strongSelf.pollingStatus(for: updatedCredential)
                        } else {
                            strongSelf.credentials[credential.id] = updatedCredential
                        }
                    } else {
                        fatalError("No such credential with " + credential.id.rawValue)
                    }
                } catch let error {
                    print(error)
                }
            }
        })
    }
    
    // Credential Observer
    typealias ObserverHandler = (_ tokenIdentifier: UUID) -> Void
    var credentialStoreObservers: [UUID: ObserverHandler] = [:]
    func addCredentialsObserver(token: StoreObserverToken, handler: @escaping ObserverHandler) {
        token.addReleaseHandler { [weak self] in
            self?.credentialStoreObservers[token.identifier] = nil
        }
        credentialStoreObservers[token.identifier] = handler
    }
}
