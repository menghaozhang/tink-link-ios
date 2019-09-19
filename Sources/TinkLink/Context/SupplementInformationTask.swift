public class SupplementInformationTask {
    private let credentialStore = CredentialStore.shared
    public private(set) var credential: Credential
    
    init(credential: Credential) {
        self.credential = credential
    }

    public func submit(_ form: Form) {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: form.makeFields()) { [weak credentialStore, credential] result in
            do {
                try result.get()
                credentialStore?.pollingStatus(for: credential)
            } catch {
                // TODO: Handle Error
            }
        }
    }
    
    public func cancel() {
        credentialStore.cancelSupplementInformation(for: credential) { [weak credentialStore, credential] result in
            do {
                try result.get()
                credentialStore?.pollingStatus(for: credential)
            } catch {
                // TODO: Handle Error
            }
        }
    }
}
