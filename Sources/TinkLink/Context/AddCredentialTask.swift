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
    private let storeObserverToken = StoreObserverToken()

    private(set) var credential: Credential?

    let progressHandler: (Status) -> Void
    let completion: (Result<Credential, Swift.Error>) -> Void

    var callCanceller: Cancellable?

    init(progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credential, Swift.Error>) -> Void) {
        self.progressHandler = progressHandler
        self.completion = completion
    }

    func startObserving(_ credential: Credential) {
        self.credential = credential

        handleUpdate(for: credential)

        credentialStore.addCredentialsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let self = self, self.storeObserverToken.has(id: tokenId) else {
                return
            }
            if let credential = self.credentialStore.credentials[credential.id], let value = self.credential {
                if value.status != credential.status {
                    self.handleUpdate(for: credential)
                } else if value.status == .updating || value.status == .awaitingSupplementalInformation {
                    self.handleUpdate(for: credential)
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
            progressHandler(.updating(status: credential.statusPayload))
        case .updated:
            completion(.success(credential))
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
