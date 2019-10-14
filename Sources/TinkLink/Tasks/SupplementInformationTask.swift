public class SupplementInformationTask {
    private let credentialService: CredentialService
    private var callRetryCancellable: RetryCancellable?
    public private(set) var credential: Credential

    private let completionHandler: (Result<Void, Error>) -> Void

    init(tinkLink: TinkLink = .shared, credential: Credential, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.credentialService = tinkLink.client.credentialService
        self.credential = credential
        self.completionHandler = completionHandler
    }

    public func submit(_ form: Form) {
        callRetryCancellable = credentialService.supplementInformation(credentialID: credential.id, fields: form.makeFields(), completion: { [weak self] result in
            self?.completionHandler(result)
            self?.callRetryCancellable = nil
        })
    }

    public func cancel() {
        callRetryCancellable = credentialService.cancelSupplementInformation(credentialID: credential.id, completion: { [weak self] result in
            self?.completionHandler(result)
            self?.callRetryCancellable = nil
        })
    }
}
