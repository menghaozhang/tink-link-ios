import Foundation

public class CredentialContext {

    public private(set) var credentials: [Identifier<Credential>: Credential] = [:]
    private let credentialStore = CredentialStore.shared
    private let storeObserverToken = StoreObserverToken()
    
    private var addCredentialTasks: [Identifier<Credential>: AddCredentialTask] = [:]

    public init() {
        credentials = credentialStore.credentials
        credentialStore.addCredentialsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf.credentials.forEach({ (key, value) in
                if let credential = strongSelf.credentialStore.credentials[key] {
                    // TODO: Make credential equatable
                    if value.status != credential.status {
                        strongSelf.handleUpdate(for: credential)
                    } else if value.status == .updating || value.status == .awaitingSupplementalInformation {
                        strongSelf.handleUpdate(for: credential)
                    }
                }
            })
            strongSelf.credentials = strongSelf.credentialStore.credentials
        }
    }
    
    public func addCredential(for provider: Provider, fields: [Provider.FieldSpecification], progressHandler: @escaping (AddCredentialTask.Status) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) -> AddCredentialTask {
        let task = AddCredentialTask(progressHandler: progressHandler, completion: completion)
        task.context = self
        task.callCanceller = credentialStore.addCredential(for: provider, fields: fields) { [weak task] result in
            do {
                let credential = try result.get()
                task?.handleUpdate(for: credential)
            } catch {
                completion(.failure(error))
            }
        }
        return task
    }
    
    private func handleUpdate(for credential: Credential) {
        guard let task = addCredentialTasks[credential.id] else { return }
        task.handleUpdate(for: credential)
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [Provider.FieldSpecification]) {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: supplementalInformationFields)
    }
    
    func cancelSupplementInformation(for credential: Credential) {
        credentialStore.cancelSupplementInformation(for: credential)
    }
}
