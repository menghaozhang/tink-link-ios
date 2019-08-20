/// The credentials model represents users connected providers from where financial data is accessed.
struct Credential {
    /// The unique identifier of the credentials.
    var id: String

    /// The provider (financial institution) that the credentials is connected to.
    var providerName: String

    enum `Type` {
        case unknown
        case password
        case mobileBankID
        case keyfob
        case fraud
        case thirdPartyAuthentication
    }

    /// Indicates how Tink authenticates the user to the financial institution.
    var type: `Type`

    enum Status {
        case unknown
        case created
        case authenticating
        case updating
        case updated
        case temporaryError
        case authenticationError
        case permanentError
        @available(*, deprecated, message: "Will be replaced with `awaitingThirdPartyAppAuthentication`")
        case awaitingMobileBankIDAuthentication
        case awaitingSupplementalInformation
        case disabled
        case awaitingThirdPartyAppAuthentication
        case sessionExpired
    }

    /// The status indicates the state of the credentials. For some states there are actions which need to be performed on the credentials.
    var status: Status

    /// A user-friendly message connected to the status. Could be an error message or text describing what is currently going on in the refresh process.
    var statusPayload: String

    /// A timestamp of when the credential's status was last modified.
    var statusUpdated: Date?

    /// A timestamp of when the credentials was the last time in status `.updated`.
    var updated: Date?

    /// This is a key-value map of Field name and value found on the Provider to which the credentials belongs to.
    var fields: [String: String]

    /// A key-value structure to handle if status of credentials are `.awaitingSupplementalInformation`.
    var supplementalInformationFields: [Provider.FieldSpecification]

    struct ThirdPartyAppAuthentication {
        // TODO:
    }

    var thirdPartyAppAuthentication: ThirdPartyAppAuthentication?

    /// Indicates when the session of credentials with access type OPEN_BANKING will expire. After this date automatic refreshes will not be possible without new authentication from the user.
    var sessionExpiryDate: Date?
}
