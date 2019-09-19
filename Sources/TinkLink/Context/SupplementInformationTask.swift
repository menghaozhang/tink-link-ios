public class SupplementInformationTask {
    private let credentialService = TinkLink.shared.client.credentialService
    public private(set) var credential: Credential

    private let completionHandler: (Result<Void, Error>) -> Void

    init(credential: Credential, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.credential = credential
        self.completionHandler = completionHandler
    }

    public func submit(_ form: Form) {
        credentialService.supplementInformation(credentialID: credential.id, fields: form.makeFields(), completion: completionHandler)
    }
    
    public func cancel() {
        credentialService.cancelSupplementInformation(credentialID: credential.id, completion: completionHandler)
    }
}
