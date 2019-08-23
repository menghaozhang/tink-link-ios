import Foundation

class CredentialContextWithCallBack {
    enum AddCredentialStatus {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(supplementalInformation: [Provider.FieldSpecification], update: ([String: String]) -> Void)
        case awaitingThirdPartyAppAuthentication(thirdPartyURL: URL)
    }
    
    var client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    private var credentials: [String: Credential] = [:]
    
    func addCredential(for provider: Provider, fields: [String: String], progressHandler: @escaping(AddCredentialStatus) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            var credential = Credential(id: "1", type: provider.credentialType, status: .created, providerName: provider.name, sessionExpiryDate: nil, supplementalInformationFields: [], fields: fields)
            progressHandler(.created)
            // observe changes
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                credential.status = .awaitingSupplementalInformation
                credential.supplementalInformationFields = [Provider.inputCodeFieldSpecification]
                progressHandler(
                    .awaitingSupplementalInformation(supplementalInformation: [Provider.inputCodeFieldSpecification],
                                                     update: { fields in
                                                        self.addSupplementalInformation(for: credential, supplementalInformationFields: fields)
                                                    })
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    credential.status = .updating
                    progressHandler(.updating(status: "Analysing"))
                    // After multiple updates
                    // Credential updated
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        credential.status = .updated
                        completion(.success(credential))
                    })
                })
            })
        }
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String]) {
        
    }
}


class AddCredentialController {
    var credentialContextWithCallBack = CredentialContextWithCallBack(client: Client(clientId: "test"))
    
    func addCredential(for provider: Provider) {
        credentialContextWithCallBack.addCredential(for: provider, fields: [:], progressHandler: { addCredentialStatus in
            switch addCredentialStatus {
            case let .awaitingSupplementalInformation(supplementalInformation, update):
                // Do something to update the supplementalInformation
                let result = supplementalInformation.createCredentialValues()
                switch result {
                case .failure:
                    break
                case .success(let updatedFields):
                    update(updatedFields)
                }
            default:
                break
            }
        }) { (result) in
            switch result {
            case .failure(let error):
                //handle error
                break
            case .success(let credential):
                // credential updated
                break
            }
        }
    }
}

