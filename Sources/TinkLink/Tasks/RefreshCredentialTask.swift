import Foundation

/// A task that manages progress of refreshing a credential.
///
/// Use `CredentialContext` to create a task.
public final class RefreshCredentialTask {
    /// Indicates the state of a credential being refreshed.
    ///
    /// - Note: For some states there are actions which need to be performed on the credentials.
    public enum Status {
        /// When the credential has just been created
        case created(credential: Credential)

        /// When starting the authentication process
        case authenticating(credential: Credential)

        /// User has been successfully authenticated, now downloading data.
        case updating(credential: Credential, status: String)

        /// Trigger for the client to prompt the user to fill out supplemental information.
        case awaitingSupplementalInformation(credential: Credential, task: SupplementInformationTask)

        /// Trigger for the client to prompt the user to open the third party authentication flow
        case awaitingThirdPartyAppAuthentication(credential: Credential, task: ThirdPartyAppAuthenticationTask)

        /// The session has expired.
        case sessionExpired(credential: Credential)

        case updated(credential: Credential)

        case error(credential: Credential, error: Error)
    }

    /// Error that the `RefreshCredentialTask` can throw.
    public enum Error: Swift.Error {
        /// The authentication failed.
        case authenticationFailed
        /// A temporary failure occurred.
        case temporaryFailure
        /// A permanent failure occurred.
        case permanentFailure
    }

    private var credentialStatusPollingTask: CredentialsListStatusPollingTask?

    private(set) public var credentials: [Credential]

    /// Cases to evaluate when credential status changes.
    ///
    /// Use with `CredentialContext.refreshCredentials(for:form:completionPredicate:progressHandler:completion:)` to set when add credential task should call completion handler if successful.
    public enum CompletionPredicate {
        /// A predicate that indicates the credential's status is `updating`.
        case updating
        /// A predicate that indicates the credential's status is `updated`.
        case updated
    }

    /// Predicate for when credential task is completed.
    ///
    /// Task will execute it's completion handler if the credential's status changes to match this predicate.

    private let credentialService: CredentialService
    let progressHandler: (Status) -> Void
    let completion: (Result<[Credential], Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(credentials: [Credential], credentialService: CredentialService, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<[Credential], Swift.Error>) -> Void) {
        self.credentials = credentials
        self.credentialService = credentialService
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving() {
        credentialStatusPollingTask = CredentialsListStatusPollingTask(
            credentialService: credentialService,
            credentials: credentials,
            updateHandler: { [weak self] result in self?.handleUpdate(for: result) },
            completion: completion)

        credentialStatusPollingTask?.pollStatus()
        // Set the callCanceller to cancel the polling
        callCanceller = credentialStatusPollingTask?.callRetryCancellable
    }

    /// Cancel the task.
    public func cancel() {
        callCanceller?.cancel()
    }

    private func handleUpdate(for result: Result<Credential, Swift.Error>) {
        do {
            let credential = try result.get()
            switch credential.status {
            case .created:
                progressHandler(.created(credential: credential))
            case .authenticating:
                progressHandler(.authenticating(credential: credential))
            case .awaitingSupplementalInformation:
                credentialStatusPollingTask?.pauseTask()
                let supplementInformationTask = SupplementInformationTask(credentialService: credentialService, credential: credential) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask?.continueTask()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingSupplementalInformation(credential: credential, task: supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                guard let thirdPartyAppAuthentication = credential.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third pary app authentication deeplink URL!")
                    return
                }
                credentialStatusPollingTask?.pauseTask()
                let task = ThirdPartyAppAuthenticationTask(thirdPartyAppAuthentication: thirdPartyAppAuthentication) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask?.continueTask()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingThirdPartyAppAuthentication(credential: credential, task: task))
            case .updating:
                progressHandler(.updating(credential: credential, status: credential.statusPayload))
            case .updated:
                progressHandler(.updated(credential: credential))
            case .sessionExpired:
                progressHandler(.sessionExpired(credential: credential))
            case .authenticationError:
                progressHandler(.error(credential: credential, error: .authenticationFailed))
            case .permanentError:
                progressHandler(.error(credential: credential, error: .permanentFailure))
            case .temporaryError:
                progressHandler(.error(credential: credential, error: .temporaryFailure))
            case .disabled:
                fatalError("Credential shouldn't be disabled during creation.")
            case .unknown:
                assertionFailure("Unknown credential status!")
            }
        } catch {
            completion(.failure(error))
        }
    }
}
