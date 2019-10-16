import Foundation

/// A protocol that allows a delegate to respond to credential changes or errors.
public protocol CredentialContextDelegate: AnyObject {
    /// Notifies the delegate that the credentials are about to be changed.
    ///
    /// - Note: This method is optional.
    /// - Parameter context: The credential context that will change.
    func credentialContextWillChangeCredentials(_ context: CredentialContext)

    /// Notifies the delegate that an error occured while fetching credentials or adding a credential.
    ///
    /// - Parameter context: The credential context that encountered the error.
    /// - Parameter error: A description of the error.
    func credentialContext(_ context: CredentialContext, didReceiveError error: Error)

    /// Notifies the delegate that the credentials has changed.
    ///
    /// - Parameter context: The credential context that changed.
    func credentialContextDidChangeCredentials(_ context: CredentialContext)
}

extension CredentialContextDelegate {
    public func credentialContextWillChangeCredentials(_ context: CredentialContext) {}
}

/// An object that you use to access the user's credentials and supports the flow for adding credentials.
public class CredentialContext {
    private var _credentials: [Credential]? {
        willSet {
            delegate?.credentialContextWillChangeCredentials(self)
        }
        didSet {
            delegate?.credentialContextDidChangeCredentials(self)
        }
    }

    /// The user's credentials.
    ///
    /// - Note: The credentials could be empty at first or change as credentials are added or updated. Use the delegate to get notified when credentials change.
    public var credentials: [Credential] {
        guard let credentials = _credentials else {
            let storedCredentials = credentialStore.credentials
                .values
                .sorted(by: { $0.id.value < $1.id.value })
            _credentials = storedCredentials
            performFetchIfNeeded()
            return storedCredentials
        }
        return credentials
    }

    /// The object that acts as the delegate of the credential context.
    ///
    /// If you set a delegate for the credential context, it will register to receive updates when credentials are added. The context notifies the delegate when `credentials` will or did change or if an error occured.
    ///
    /// - Note: The delegate must adopt the `CredentialContextDelegate` protocol. The delegate is not retained.
    public weak var delegate: CredentialContextDelegate? {
        didSet {
            if delegate != nil {
                addStoreObservers()
                performFetchIfNeeded()
            } else {
                removeStoreObservers()
            }
        }
    }

    private let tinkLink: TinkLink
    private let credentialStore: CredentialStore
    private var credentialStoreChangeObserver: Any?
    private var credentialStoreErrorObserver: Any?

    private var service: CredentialService
    private let authenticationManager: AuthenticationManager
    private let locale: Locale

    private var fetchCredentialsRetryCancellable: RetryCancellable?

    /// Creates a new CredentialContext for the given TinkLink instance.
    ///
    /// - Parameter tinkLink: TinkLink instance, defaults to `shared` if not provided.
    public init(tinkLink: TinkLink = .shared) {
        self.tinkLink = tinkLink
        self.credentialStore = tinkLink.credentialStore
        self.authenticationManager = tinkLink.authenticationManager
        self.service = tinkLink.client.credentialService
        self.locale = tinkLink.client.locale
    }

    private func addStoreObservers() {
        credentialStoreChangeObserver = NotificationCenter.default.addObserver(forName: .credentialStoreChanged, object: credentialStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self._credentials = self.credentialStore.credentials
                .values
                .sorted(by: { $0.id.value < $1.id.value })
        }
    }

    private func removeStoreObservers() {
        credentialStoreChangeObserver = nil
        credentialStoreErrorObserver = nil
    }

    /// Adds a credential for the user.
    ///
    /// You need to handle status changes in `progressHandler` to successfuly add a credential for some providers.
    ///
    ///     credentialContext.addCredential(for: provider, form: form, progressHandler: { status in
    ///         switch status {
    ///         case .awaitingSupplementalInformation(let supplementInformationTask):
    ///             <#Present form for supplemental information task#>
    ///         case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication):
    ///             <#Open third party app deep link URL#>
    ///         default:
    ///             break
    ///         }
    ///     }, completion: { result in
    ///         <#Handle result#>
    ///     }
    ///
    /// - Parameters:
    ///   - provider: The provider (financial institution) that the credentials is connected to.
    ///   - form: This is a form with fields from the Provider to which the credentials belongs to.
    ///   - completionPredicate: Predicate for when credential task should complete.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credential being added.
    ///   - completion: The block to execute when the credential has been added successfuly or if it failed.
    ///   - result: Represents either a successfully added credential or an error if adding the credential failed.
    /// - Returns: The add credential task.
    public func addCredential(for provider: Provider, form: Form, completionPredicate: AddCredentialTask.CompletionPredicate = .updated, progressHandler: @escaping (_ status: AddCredentialTask.Status) -> Void, completion: @escaping (_ result: Result<Credential, Error>) -> Void) -> AddCredentialTask {
        let task = AddCredentialTask(
            tinkLink: tinkLink,
            completionPredicate: completionPredicate,
            progressHandler: progressHandler,
            completion: completion,
            credentialUpdateHandler: { [weak self] result in
                guard let self = self else { return }
                do {
                    let credential = try result.get()
                    self.credentialStore.update(credential: credential)
                } catch {
                    self.delegate?.credentialContext(self, didReceiveError: error)
                }
            }
        )

        let appURI = tinkLink.configuration.redirectURI

        task.callCanceller = addCredentialAndAuthenticateIfNeeded(for: provider, fields: form.makeFields(), appURI: appURI) { [weak self, weak task] result in
            guard let self = self else { return }
            do {
                let credential = try result.get()
                self.credentialStore.update(credential: credential)
                task?.startObserving(credential)
            } catch {
                completion(.failure(error))
                self.delegate?.credentialContext(self, didReceiveError: error)
            }
        }
        return task
    }

    func performFetchIfNeeded() {
        if fetchCredentialsRetryCancellable == nil {
            performFetch()
        }
    }

    private func performFetch() {
        fetchCredentialsRetryCancellable = service.credentials { [weak self] result in
            guard let self = self else { return }
            do {
                let credentials = try result.get()
                self.credentialStore.store(credentials)
            } catch {
                self.delegate?.credentialContext(self, didReceiveError: error)
            }
            self.fetchCredentialsRetryCancellable = nil
        }
    }

    private func addCredentialAndAuthenticateIfNeeded(for provider: Provider, fields: [String: String], appURI: URL, completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable {
        let multiHandler = MultiHandler()
        let market = Market(code: provider.marketCode)

        let authHandler = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { result in
            do {
                try result.get()
                let handler = self.service.createCredential(providerID: provider.id, fields: fields, appURI: appURI, completion: completion)
                multiHandler.add(handler)
            } catch {
                completion(.failure(error))
            }
        }
        if let handler = authHandler {
            multiHandler.add(handler)
        }
        return multiHandler
    }
}
