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

    var callCanceller: Cancellable?

    public func cancel() {
        callCanceller?.cancel()
    }
}
