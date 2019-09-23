import Foundation

public protocol CredentialContextDelegate: AnyObject {
    func credentialContextWillChangeCredentials(_ context: CredentialContext)
    func credentialContext(_ context: CredentialContext, didReceiveError error: Error)
    func credentialContextDidChangeCredentials(_ context: CredentialContext)
}

extension CredentialContextDelegate {
    public func credentialContextWillChangeCredentials(_ context: CredentialContext) { }
}

/// An object that accesses the user's credentials and supports the flow for adding credentials.
public class CredentialContext {

    private var _credentials: [Credential]? {
        willSet {
            delegate?.credentialContextWillChangeCredentials(self)
        }
        didSet {
            delegate?.credentialContextDidChangeCredentials(self)
        }
    }

    var credentials: [Credential] {
        guard let credentials = _credentials else {
            let storedCredentials = credentialStore.credentials
                .values
                .sorted(by: { $0.id.rawValue < $1.id.rawValue })
            _credentials = storedCredentials
            performFetch()
            return storedCredentials
        }
        return credentials
    }

    weak var delegate: CredentialContextDelegate? {
        didSet {
            if delegate != nil {
                addStoreObservers()
                performFetch()
            } else {
                removeStoreObservers()
            }
        }
    }

    private let credentialStore = CredentialStore.shared
    private var credentialStoreChangeObserver: Any?
    private var credentialStoreErrorObserver: Any?
    
    public init() {

    }

    private func addStoreObservers() {
        credentialStoreChangeObserver = NotificationCenter.default.addObserver(forName: .credentialStoreChanged, object: credentialStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self._credentials = self.credentialStore.credentials
                .values
                .sorted(by: { $0.id.rawValue < $1.id.rawValue })
        }

        credentialStoreErrorObserver = NotificationCenter.default.addObserver(forName: .credentialStoreErrorOccured, object: credentialStore, queue: .main) { [weak self] notification in
            guard let self = self, let error = notification.userInfo?[CredentialStoreErrorOccuredNotificationErrorKey] as? Error else { return }
            self.delegate?.credentialContext(self, didReceiveError: error)
        }
    }

    private func removeStoreObservers() {
        credentialStoreChangeObserver = nil
        credentialStoreErrorObserver = nil
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
        let task = AddCredentialTask(
            progressHandler: progressHandler,
            completion: completion,
            credentialUpdateHandler: { [weak self] credential in
               self?.credentialStore.credentials[credential.id] = credential
        })
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

    private func performFetch() {
        credentialStore.performFetchIfNeeded()
    }
}
