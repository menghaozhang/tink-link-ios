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
        case awaitingSupplementalInformation(credential: Credential, SupplementInformationTask)

        /// Trigger for the client to prompt the user to open the third party authentication flow
        case awaitingThirdPartyAppAuthentication(credential: Credential, ThirdPartyAppAuthenticationTask)

        /// The session has expired.
        case sessionExpired(credential: Credential)
    }

    /// Error that the `AddCredentialTask` can throw.
    public enum Error: Swift.Error {
        /// The authentication failed.
        case authenticationFailed
        /// A temporary failure occurred.
        case temporaryFailure
        /// A permanent failure occurred.
        case permanentFailure
    }

    private var credentialStatusPollingTask: CredentialStatusPollingTask?

    private(set) public var credential: Credential

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
    public let completionPredicate: CompletionPredicate

    private let credentialService: CredentialService
    private var previousStatus: Credential.Status?
    let progressHandler: (Status) -> Void
    let completion: (Result<Credential, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(credential: Credential, credentialService: CredentialService, completionPredicate: CompletionPredicate = .updated, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credential, Swift.Error>) -> Void) {
        self.credential = credential
        self.credentialService = credentialService
        self.completionPredicate = completionPredicate
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving() {

        credentialStatusPollingTask = CredentialStatusPollingTask(credentialService: credentialService, credential: credential) { [weak self] result in
            self?.handleUpdate(for: result)
        }

        credentialStatusPollingTask?.pollStatus()
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
                let supplementInformationTask = SupplementInformationTask(credentialService: credentialService, credential: credential) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask = CredentialStatusPollingTask(credentialService: self.credentialService, credential: credential, updateHandler: self.handleUpdate)
                        self.credentialStatusPollingTask?.pollStatus()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingSupplementalInformation(credential: credential, supplementInformationTask))
            case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
                guard let thirdPartyAppAuthentication = credential.thirdPartyAppAuthentication else {
                    assertionFailure("Missing third pary app authentication deeplink URL!")
                    return
                }
                let task = ThirdPartyAppAuthenticationTask(thirdPartyAppAuthentication: thirdPartyAppAuthentication) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        try result.get()
                        self.credentialStatusPollingTask = CredentialStatusPollingTask(credentialService: self.credentialService, credential: credential, updateHandler: self.handleUpdate)
                        self.credentialStatusPollingTask?.pollStatus()
                    } catch {
                        self.completion(.failure(error))
                    }
                }
                progressHandler(.awaitingThirdPartyAppAuthentication(credential: credential, task))
            case .updating:
                if completionPredicate == .updating {
                    completion(.success(credential))
                } else {
                    progressHandler(.updating(credential: credential, status: credential.statusPayload))
                }
            case .updated:
                if completionPredicate == .updated {
                    completion(.success(credential))
                }
            case .sessionExpired:
                progressHandler(.sessionExpired(credential: credential))
            case .authenticationError:
                completion(.failure(RefreshCredentialTask.Error.authenticationFailed))
            case .permanentError:
                completion(.failure(RefreshCredentialTask.Error.permanentFailure))
            case .temporaryError:
                completion(.failure(RefreshCredentialTask.Error.temporaryFailure))
            case .disabled:
                fatalError("Credential shouldn't be disabled during creation.")
            case .unknown:
                assertionFailure("Unknown credential status!")
            }
            previousStatus = credential.status
        } catch {
            completion(.failure(error))
        }
    }
}
