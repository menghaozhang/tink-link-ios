public class SupplementInformationTask {
    public init(credentialContext: CredentialContext, credential: Credential) {
        self.credential = credential
        fields = credential.supplementalInformationFields
        self.credentialContext = credentialContext
    }

    weak var credentialContext: CredentialContext?

    public private(set) var credential: Credential
    public var fields: [Provider.FieldSpecification]

    public func submit() {
        credentialContext?.addSupplementalInformation(for: credential, supplementalInformationFields: fields)
    }

    public func cancel() {
        credentialContext?.cancelSupplementInformation(for: credential)
    }
}
