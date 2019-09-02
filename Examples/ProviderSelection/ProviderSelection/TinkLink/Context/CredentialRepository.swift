import Foundation

class SupplementInformationTask {
    init(credentialRepository: CredentialRepository, credential: Credential) {
        self.credential = credential
        fields = credential.supplementalInformationFields
        self.credentialRepository = credentialRepository
    }
    weak var credentialRepository: CredentialRepository?
    private(set) var credential: Credential
    var fields: [Provider.FieldSpecification]
    
    func submit() {
        if let fields = try? fields.createCredentialValues().get() {
            credentialRepository?.addSupplementalInformation(for: credential, supplementalInformationFields: fields)
        }
    }
    
    func cancel() {
        credentialRepository?.cancelSupplementInformation(for: credential)
    }
}

class CredentialRepository {
    enum AddCredentialStatus {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(URL)
    }
    
    private let credentialStore = CredentialStore.shared
    private let storeObserverToken = StoreObserverToken()
    
    private var credentials: [String: Credential] = [:]
    private var progressHandlers: [String: (AddCredentialStatus) -> Void] = [:]
    private var completions: [String: (Result<Credential, Error>) -> Void] = [:]
    
    init() {
        credentials = credentialStore.credentials
        credentialStore.addCredentialsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf.credentials.forEach({ (key, value) in
                if let credential = strongSelf.credentialStore.credentials[key] {
                    if value.status != credential.status {
                        strongSelf.handleUpdate(for: credential)
                    }
                }
            })
            strongSelf.credentials = strongSelf.credentialStore.credentials
        }
    }
    
    
    func addCredential(for provider: Provider, fields: [String: String], progressHandler: @escaping (AddCredentialStatus) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) {
        credentialStore.addCredential(for: provider, fields: fields) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let credential):
                strongSelf.progressHandlers[credential.id] = progressHandler
                strongSelf.completions[credential.id] = completion
            }
        }
    }
    
    private func handleUpdate(for credential: Credential) {
        guard let progressHandler = progressHandlers[credential.id], let completion = completions[credential.id] else { return }
        switch credential.status {
        case .created:
            progressHandler(.created)
        case .authenticating:
            progressHandler(.authenticating)
        case .awaitingSupplementalInformation:
            let supplementInformationTask = SupplementInformationTask(credentialRepository: self, credential: credential)
            progressHandler(.awaitingSupplementalInformation(supplementInformationTask))
        case .awaitingThirdPartyAppAuthentication:
            progressHandler(.awaitingThirdPartyAppAuthentication(URL(string: "https://www.google.com")!))
        case .updating:
            progressHandler(.updating(status: "fetching transaction"))
        case .updated:
            completion(.success(credential))
        default:
            completion(.failure(NSError()))
        }
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String]) {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: supplementalInformationFields)
    }
    
    func cancelSupplementInformation(for credential: Credential) {
        credentialStore.cancelSupplementInformation(for: credential)
    }
}
