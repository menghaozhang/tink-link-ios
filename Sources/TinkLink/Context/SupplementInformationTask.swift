public class SupplementInformationTask {
    private let credentialStore = CredentialStore.shared
    public private(set) var credential: Credential
    
    public init(credential: Credential) {
        self.credential = credential
    }

    public func submit(_ form: Form) {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: form.makeFields())
    }
    
    public func cancel() {
        credentialStore.cancelSupplementInformation(for: credential)
    }
}
