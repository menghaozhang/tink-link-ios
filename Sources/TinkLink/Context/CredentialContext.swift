import Foundation

public class SupplementInformationTask {
    public init(credentialContext: CredentialContext, credential: Credential) {
        self.credential = credential
        fields = credential.supplementalInformationFields
        self.credentialContext = credentialContext
    }
    private weak var credentialContext: CredentialContext?
    public private(set) var credential: Credential
    public var fields: [Provider.FieldSpecification]
    
    public func submit() {
        credentialContext?.addSupplementalInformation(for: credential, supplementalInformationFields: fields)
    }
    
    public func cancel() {
        credentialContext?.cancelSupplementInformation(for: credential)
    }
}

public class CredentialContext {
    public enum AddCredentialStatus {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(URL)
    }
    
    public private(set) var credentials: [Identifier<Credential>: Credential] = [:]
    private let credentialStore = CredentialStore.shared
    private let storeObserverToken = StoreObserverToken()
    
    private var progressHandlers: [Identifier<Credential>: (AddCredentialStatus) -> Void] = [:]
    private var completions: [Identifier<Credential>: (Result<Credential, Error>) -> Void] = [:]
    
    public init() {
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
    
    public func addCredential(for provider: Provider, fields: [Provider.FieldSpecification], progressHandler: @escaping (AddCredentialStatus) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) {
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
            let supplementInformationTask = SupplementInformationTask(credentialContext: self, credential: credential)
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
    
    fileprivate func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [Provider.FieldSpecification]) {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: supplementalInformationFields)
    }
    
    fileprivate func cancelSupplementInformation(for credential: Credential) {
        credentialStore.cancelSupplementInformation(for: credential)
    }
}
