import Foundation

public class AddCredentialTask {
    /// Indicates the state of a credential being added.
    ///
    /// - Note: For some states there are actions which need to be performed on the credentials.
    public enum Status {
        /// Initial status
        case created

        /// When starting the authentication process
        case authenticating

        /// User has been successfully authenticated, now downloading data.
        case updating(status: String)

        /// Trigger for the client to prompt the user to fill out supplemental information.
        case awaitingSupplementalInformation(SupplementInformationTask)

        /// Trigger for the client to prompt the user to open the third party authentication flow
        case awaitingThirdPartyAppAuthentication(Credential.ThirdPartyAppAuthentication)
    }

    public enum Error: Swift.Error {
        case authenticationFailed
        case temporaryFailure
        case permanentFailure
    }

    private var credentialStatusPollingTask: CredentialStatusPollingTask?

    private(set) var credential: Credential?

    enum CompletionPredicate {
        case updating
        case updated
    }
    let completionPredicate: CompletionPredicate

    let progressHandler: (Status, Credential) -> Void
    let completion: (Result<Credential, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(completionPredicate: CompletionPredicate = .updated, progressHandler: @escaping (Status, Credential) -> Void, completion: @escaping (Result<Credential, Swift.Error>) -> Void) {
        self.completionPredicate = completionPredicate
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving(_ credential: Credential) {
        self.credential = credential

        handleUpdate(for: credential)

        credentialStatusPollingTask = CredentialStatusPollingTask(credential: credential, updateHandler: handleUpdate)
        credentialStatusPollingTask?.pollStatus()
    }

    public func cancel() {
        callCanceller?.cancel()
    }

    private func handleUpdate(for credential: Credential) {
        switch credential.status {
        case .created:
            progressHandler(.created, credential)
        case .authenticating:
            progressHandler(.authenticating, credential)
        case .awaitingSupplementalInformation:
            let supplementInformationTask = SupplementInformationTask(credential: credential) { [weak self] result in
                guard let self = self else { return }
                do {
                    try result.get()
                    self.credentialStatusPollingTask = CredentialStatusPollingTask(credential: credential, updateHandler: self.handleUpdate)
                    self.credentialStatusPollingTask?.pollStatus()
                } catch {
                    self.completion(.failure(error))
                }
            }
            progressHandler(.awaitingSupplementalInformation(supplementInformationTask), credential)
        case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
            guard let thirdPartyAppAuthentication = credential.thirdPartyAppAuthentication else {
                assertionFailure("Missing third pary app authentication deeplink URL!")
                return
            }
            progressHandler(.awaitingThirdPartyAppAuthentication(thirdPartyAppAuthentication), credential)
        case .updating:
            if completionPredicate == .updating {
                completion(.success(credential))
            } else {
                progressHandler(.updating(status: credential.statusPayload), credential)
            }
        case .updated:
            if completionPredicate == .updated {
                completion(.success(credential))
            }
        case .permanentError:
            completion(.failure(AddCredentialTask.Error.permanentFailure))
        case .temporaryError:
            completion(.failure(AddCredentialTask.Error.temporaryFailure))
        case .authenticationError:
            completion(.failure(AddCredentialTask.Error.authenticationFailed))
        case .disabled:
            fatalError("Credential shouldn't be disabled during creation.")
        case .sessionExpired:
            fatalError("Credential's session shouldn't expire during creation.")
        case .unknown:
            assertionFailure("Unknown credential status!")
        }
    }
}
