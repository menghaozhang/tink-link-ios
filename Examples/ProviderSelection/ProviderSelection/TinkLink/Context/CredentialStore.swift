import Foundation

class CredentialStore {
    enum AddCredentialStatus {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(URL)
    }
    static let shared = CredentialStore()
    
    var credentials: [String: Credential] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.credentialStoreObservers.forEach { (tokenID, handler) in
                    handler(tokenID)
                }
            }
        }
    }
    private var service: CredentialService
    
    private init() {
        service = CredentialService(client: TinkLink.shared.client)
    }
    
    func addCredential(for provider: Provider, fields: [String: String], completion: @escaping(Result<Credential, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            // observe changes
            self.service.createCredential(for: provider, fields: fields, completion: { [weak self] (result) in
                guard let strongSelf = self else { return }
                let credential = try! result.get()
                strongSelf.credentials[credential.id] = credential
                completion(.success(credential))
            })
        }
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String]) {
        self.service.supplementInformation(credentialID: credential.id, fields: supplementalInformationFields) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure:
                break
            case .success(let credential):
                strongSelf.credentials[credential.id] = credential
            }
        }
    }
    
    func cancelSupplementInformation(for credential: Credential) {
        service.cancelSupplementInformation(credentialID: credential.id) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure:
                break
            case .success(let credential):
                strongSelf.credentials[credential.id] = credential
            }
        }
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
