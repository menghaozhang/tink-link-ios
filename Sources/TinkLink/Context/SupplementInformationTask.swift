public class SupplementInformationTask {
    private let credentialStore = CredentialStore.shared

    public private(set) var credential: Credential
    public var fields: [Provider.FieldSpecification]

    public init(credential: Credential) {
        self.credential = credential
        fields = credential.supplementalInformationFields
    }

    public func submit() {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: fields)
    }

    public func cancel() {
        credentialStore.cancelSupplementInformation(for: credential)
    }
}
