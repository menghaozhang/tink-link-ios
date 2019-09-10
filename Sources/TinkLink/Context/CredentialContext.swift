import Foundation

public class CredentialContext {

    public private(set) var credentials: [Identifier<Credential>: Credential] = [:]
    private let credentialStore = CredentialStore.shared
    private var credentialStoreObserver: Any?
    
    public init() {
        credentials = credentialStore.credentials
        credentialStoreObserver = NotificationCenter.default.addObserver(forName: .credentialStoreChanged, object: credentialStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.credentials = self.credentialStore.credentials
        }
    }
    
    public func addCredential(for provider: Provider, fields: [Provider.FieldSpecification], progressHandler: @escaping (AddCredentialTask.Status) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) -> AddCredentialTask {
        let task = AddCredentialTask(progressHandler: progressHandler, completion: completion)
        task.callCanceller = credentialStore.addCredential(for: provider, fields: fields) { [weak task] result in
            do {
                let credential = try result.get()
                task?.startObserving(credential)
            } catch {
                completion(.failure(error))
            }
        }
        return task
    }
}
