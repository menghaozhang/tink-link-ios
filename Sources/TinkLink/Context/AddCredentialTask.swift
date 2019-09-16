import Foundation

public class AddCredentialTask {
    public enum Status {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(URL)
    }

    public enum Error: Swift.Error {
        case authenticationFailed
        case temporaryFailure
        case permanentFailure
    }

    private let credentialStore = CredentialStore.shared
    private var credentialStoreObserver: Any?

    private(set) var credential: Credential?

    enum CompletionPredicate {
        case updating
        case updated
    }
    let completionPredicate: CompletionPredicate

    let progressHandler: (Status) -> Void
    let completion: (Result<Credential, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(completionPredicate: CompletionPredicate = .updated, progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credential, Swift.Error>) -> Void) {
        self.completionPredicate = completionPredicate
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving(_ credential: Credential) {
        self.credential = credential

        handleUpdate(for: credential)

        credentialStoreObserver = NotificationCenter.default.addObserver(forName: .credentialStoreChanged, object: credentialStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if let updatedCredential = self.credentialStore.credentials[credential.id], let initialCredential = self.credential {
                if initialCredential.status != updatedCredential.status {
                    self.handleUpdate(for: updatedCredential)
                } else if initialCredential.status == .updating || initialCredential.status == .awaitingSupplementalInformation {
                    self.handleUpdate(for: updatedCredential)
                }
            }
        }
    }

    public func cancel() {
        callCanceller?.cancel()
    }

    private func handleUpdate(for credential: Credential) {
        switch credential.status {
        case .created:
            progressHandler(.created)
        case .authenticating:
            progressHandler(.authenticating)
        case .awaitingSupplementalInformation:
            let supplementInformationTask = SupplementInformationTask(credential: credential)
            progressHandler(.awaitingSupplementalInformation(supplementInformationTask))
        case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
            guard let url = credential.thirdPartyAppAuthentication?.deepLinkURL else {
                assertionFailure("Missing third pary app authentication deeplink URL!")
                return
            }
            progressHandler(.awaitingThirdPartyAppAuthentication(url))
        case .updating:
            if completionPredicate == .updating {
                completion(.success(credential))
            } else {
                progressHandler(.updating(status: credential.statusPayload))
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
