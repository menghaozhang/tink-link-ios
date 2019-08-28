import Foundation

class SupplementalInformationTask {
    init(credentialContext: CredentialContextWithCallBack, credential: Credential) {
        self.credential = credential
        fields = credential.supplementalInformationFields
        self.credentialContext = credentialContext
    }
    weak var credentialContext: CredentialContextWithCallBack?
    private var credential: Credential
    var fields: [Provider.FieldSpecification]
    
    func submitUpdate() {
        credentialContext?.addSupplementalInformation(for: credential, supplementalInformationFields: [:])
    }
    
    func cancelUpdate() {
        
    }
}

class CredentialContextWithCallBack {
    enum AddCredentialStatus {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(supplementalInformation: SupplementalInformationTask)
        case awaitingThirdPartyAppAuthentication(thirdPartyURL: URL)
    }
    
    var client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    private var credentials: [String: Credential] = [:]
    private var progressHandlers: [String: (AddCredentialStatus) -> Void] = [:]
    private var completions: [String: (Result<Credential, Error>) -> Void] = [:]
    
    func addCredential(for provider: Provider, fields: [String: String], progressHandler: @escaping (AddCredentialStatus) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            var credential = Credential(id: "1", type: provider.credentialType, status: .created, providerName: provider.name, sessionExpiryDate: nil, supplementalInformationFields: [], fields: fields)
            self.credentials[credential.id] = credential
            self.progressHandlers[credential.id] = progressHandler
            self.completions[credential.id] = completion
            progressHandler(.created)
            // observe changes
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                credential.status = .awaitingSupplementalInformation
                credential.supplementalInformationFields = [Provider.inputCodeFieldSpecification]
                progressHandler(
                    .awaitingSupplementalInformation(supplementalInformation: SupplementalInformationTask(credentialContext: self, credential: credential))
                )
            })
        }
    }
    
    fileprivate func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String]) {
        var credential = credentials[credential.id]!
        let progressHandler = progressHandlers[credential.id]!
        let completion = completions[credential.id]!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            credential.status = .updating
            progressHandler(.updating(status: "Analysing 50%"))
            // After multiple updates
            // Credential updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                credential.status = .updating
                progressHandler(.updating(status: "Analysing 80%"))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    credential.status = .updated
                    completion(.success(credential))
                })
            })
        })
    }
    
    fileprivate func cancelSupplementInformation(for credentialID: String) {
        guard let completion = completions[credentialID] else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let error = NSError(domain: "User cancelled", code: NSURLErrorCancelled)
            completion(.failure(error))
        }
    }
}
