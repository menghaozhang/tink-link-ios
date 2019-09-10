public class SupplementInformationTask {
    public init(credentialContext: CredentialContext, credential: Credential) {
        self.credential = credential
        self.credentialContext = credentialContext
    }

    weak var credentialContext: CredentialContext?

    public private(set) var credential: Credential

    public func submit(form: Form) {
        credentialContext?.addSupplementalInformation(for: credential, with: form)
    }

    public func cancel() {
        credentialContext?.cancelSupplementInformation(for: credential)
    }
}
