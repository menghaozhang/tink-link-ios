import Dispatch

class CredentialService {
    
    private var client: Client
    init(client: Client) {
        self.client = client
    }
    
    func createCredential(for provider: Provider, fields: [String: String], completion: @escaping (Result<Credential, Error>) -> Void) {
        // Received async request response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [provider] in
            let credential = Credential(id: provider.name + provider.accessType.rawValue, type: provider.credentialType, status: .created, providerName: provider.name, sessionExpiryDate: nil, supplementalInformationFields: [Provider.inputCodeFieldSpecification], fields: [:])
            self.credentials[credential.id] = credential
            completion(.success(credential))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.update(credential: credential, to: .awaitingSupplementalInformation, completion: completion)
            }
        }
    }
    
    func supplementInformation(credentialID: String, fields: [String: String], completion: @escaping(Result<Credential, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let credential = self.credentials[credentialID] {
                self.update(credential: credential, to: .updating, completion: completion)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let credential = self.credentials[credentialID] {
                    self.update(credential: credential, to: .updating, completion: completion)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if let credential = self.credentials[credentialID] {
                        self.update(credential: credential, to: .updated, completion: completion)
                    }
                })
            }
        }
    }
    
    func cancelSupplementInformation(credentialID: String, completion: @escaping (Result<Credential, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let credential = self.credentials[credentialID] {
                self.update(credential: credential, to: .created, completion: { result in
                    switch result {
                    case .success(let credential):
                        completion(.success(credential))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            }
        }
    }
    
    // Temp mock to keep the reference
    fileprivate var credentials: [String: Credential] = [:]
}

// Helper only for mock example
extension CredentialService {
    func update(credential: Credential, to status: Credential.Status, completion: @escaping(Result<Credential, Error>) -> Void) {
        var mutableCredential = self.credentials[credential.id]
        mutableCredential?.status = status
        if let credential = mutableCredential {
            completion(.success(credential))
        }
    }
}
