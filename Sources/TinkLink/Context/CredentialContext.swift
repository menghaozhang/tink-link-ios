import Foundation

/// An object that accesses the user's credentials and supports the flow for adding credentials.
public class CredentialContext {

    public private(set) var credentials: [Credential] = []
    private let credentialStore = CredentialStore.shared
    private var credentialStoreObserver: Any?
    
    public init() {
        credentials = credentialStore.credentials
            .values
            .sorted(by: { $0.id.rawValue < $1.id.rawValue })

        credentialStoreObserver = NotificationCenter.default.addObserver(forName: .credentialStoreChanged, object: credentialStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.credentials = self.credentialStore.credentials
                .values
                .sorted(by: { $0.id.rawValue < $1.id.rawValue })
        }
    }
    
    /// Adds a credential for the user.
    ///
    /// - Parameters:
    ///   - provider: The provider (financial institution) that the credentials is connected to.
    ///   - form: This is a form with fields from the Provider to which the credentials belongs to.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credential being added.
    ///   - completion: The block to execute when the credential has been added successfuly or if it failed.
    ///   - result: Represents either a successfuly added credential or an error if adding the credential failed.
    /// - Returns: The add credential task.
    public func addCredential(for provider: Provider, form: Form, progressHandler: @escaping (_ status: AddCredentialTask.Status) -> Void,  completion: @escaping (_ result: Result<Credential, Error>) -> Void) -> AddCredentialTask {
        let task = AddCredentialTask(progressHandler: progressHandler, completion: completion)
        credentialStore.addCredential(for: provider, fields: form.makeFields()) { [weak task] result in
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
