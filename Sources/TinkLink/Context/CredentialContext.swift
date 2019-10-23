import Foundation

/// An object that you use to access the user's credentials and supports the flow for adding credentials.
public class CredentialContext {
    private let tinkLink: TinkLink

    private var credentialService: CredentialService
    private let market: Market
    private let locale: Locale

    /// Creates a new CredentialContext for the given TinkLink instance.
    ///
    /// - Parameter tinkLink: TinkLink instance, defaults to `shared` if not provided.
    /// - Parameter user: `User` that will be used for adding credentials with the Tink API.
    public init(tinkLink: TinkLink = .shared, user: User) {
        self.tinkLink = tinkLink
        self.credentialService = CredentialService(tinkLink: tinkLink, accessToken: user.accessToken)
        self.market = tinkLink.client.market
        self.locale = tinkLink.client.locale
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
            credentialService: credentialService,
            completionPredicate: completionPredicate,
            progressHandler: progressHandler,
            completion: completion,
            credentialUpdateHandler: { _ in }
        )

        let appURI = tinkLink.configuration.redirectURI

        task.callCanceller = addCredentialAndAuthenticateIfNeeded(for: provider, fields: form.makeFields(), appURI: appURI) { [weak task] result in
            do {
                let credential = try result.get()
                task?.startObserving(credential)
            } catch {
                completion(.failure(error))
            }
        }
        return task
    }

    private func addCredentialAndAuthenticateIfNeeded(for provider: Provider, fields: [String: String], appURI: URL, completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable {

        return credentialService.createCredential(providerID: provider.id, fields: fields, appURI: appURI, completion: completion)
    }

    /// Gets the user's credentials.
    public func fetchCredentials(completion: @escaping (Result<[Credential], Error>) -> Void) -> RetryCancellable {
        let handler = credentialService.credentials { result in
            do {
                let credentials = try result.get()
                let storedCredentials = credentials.sorted(by: { $0.id.value < $1.id.value })
                completion(.success(storedCredentials))
            } catch {
                completion(.failure(error))
            }
        }
        return handler
    }
}
