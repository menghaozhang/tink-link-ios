import Foundation

public class AddCredentialTask {
    public enum Status {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(URL)
    }

    enum Error: Swift.Error {
        case authenticationFailed
        case temporaryFailure
        case permanentFailure
    }

    let progressHandler: (Status) -> Void
    let completion: (Result<Credential, Swift.Error>) -> Void

    weak var context: CredentialContext?

    var callCanceller: Cancellable?

    init(progressHandler: @escaping (Status) -> Void, completion: @escaping (Result<Credential, Swift.Error>) -> Void) {
        self.progressHandler = progressHandler
        self.completion = completion
    }

    public func cancel() {
        callCanceller?.cancel()
    }

    func handleUpdate(for credential: Credential) {
        switch credential.status {
        case .created:
            progressHandler(.created)
        case .authenticating:
            progressHandler(.authenticating)
        case .awaitingSupplementalInformation:
            guard let context = context else {
                assertionFailure("Missing context!")
                return
            }
            let supplementInformationTask = SupplementInformationTask(credentialContext: context, credential: credential)
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
