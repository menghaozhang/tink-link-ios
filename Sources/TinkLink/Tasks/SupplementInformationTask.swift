/// A task that handles submitting supplemental information for a credential.
///
/// This task is usually given when an AddCredentialTask's status changes to `awaitingSupplementalInformation`.
/// Use this task to submit supplmental information for the credential.
/// If the user dismiss supplementing information, by e.g. closing the form, you need to call `cancel()` to stop adding the credential.
public class SupplementInformationTask {
    private let credentialService: CredentialService
    private var callRetryCancellable: RetryCancellable?

    /// The credential that's awaiting supplemental information.
    public private(set) var credential: Credential

    private let completionHandler: (Result<Void, Error>) -> Void

    init(tinkLink: TinkLink = .shared, credential: Credential, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.credentialService = tinkLink.client.credentialService
        self.credential = credential
        self.completionHandler = completionHandler
    }

    /// Submits the provided form fields.
    ///
    /// - Parameter form: This is a form with fields from the credential that had status `awaitingSupplementalInformation`.
    public func submit(_ form: Form) {
        callRetryCancellable = credentialService.supplementInformation(credentialID: credential.id, fields: form.makeFields(), completion: { [weak self] result in
            self?.completionHandler(result)
            self?.callRetryCancellable = nil
        })
    }

    /// Tells the credential to stop waiting for supplemental information.
    ///
    /// Call this method if the user dismiss the form to supplement information.
    public func cancel() {
        callRetryCancellable = credentialService.cancelSupplementInformation(credentialID: credential.id, completion: { [weak self] result in
            self?.completionHandler(result)
            self?.callRetryCancellable = nil
        })
    }
}
