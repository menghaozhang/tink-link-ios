import Foundation

/// The credentials model represents users connected providers from where financial data is accessed.
public struct Credential {
    /// The unique identifier of the credentials.
    public var id: Identifier<Credential>

    /// The provider (financial institution) that the credentials is connected to.
    public var providerName: Identifier<Provider>

    /// Indicates how Tink authenticates the user to the financial institution.
    public var type: CredentialType

    /// The status indicates the state of a credential.
    public enum Status {
        case unknown
        /// The credential was just created.
        case created
        /// The credential is in the process of authenticating.
        case authenticating
        /// The credential is done authenticating and is updating accounts and transactions.
        case updating
        /// The credential has finished authenticating and updating accounts and transactions.
        case updated
        /// There was a temporary error, see `statusPayload` for text describing the error.
        case temporaryError
        /// There was an authentication error, see `statusPayload` for text describing the error.
        case authenticationError
        /// There was a permanent error, see `statusPayload` for text describing the error.
        case permanentError
        /// The credential is awaiting authentication with Mobile BankID.
        /// - Note: Will be deprecated and replaced with `awaitingThirdPartyAppAuthentication`
        case awaitingMobileBankIDAuthentication
        /// The credential is awaiting supplemental information.
        ///
        /// Create a Form with this credential to let the user supplement the required information.
        case awaitingSupplementalInformation
        /// The credential has been disabled.
        case disabled
        /// The credential is awaiting authentication with a third party app.
        ///
        /// Check `thirdPartyAppAuthentication` to get a deeplink url to the third party app to authenticate with.
        /// - Note: If the app can't open the deeplink, ask user to to download or upgrade the app from the AppStore.
        case awaitingThirdPartyAppAuthentication
        /// The credential's session has expired, check `sessionExpiryDate` to see when it expired.
        case sessionExpired
    }

    /// The status indicates the state of a credential. For some states there are actions which need to be performed on the credentials.
    public var status: Status

    /// A user-friendly message connected to the status. Could be an error message or text describing what is currently going on in the refresh process.
    public var statusPayload: String

    /// A timestamp of when the credential's status was last modified.
    public var statusUpdated: Date?

    /// A timestamp of when the credentials was the last time in status `.updated`.
    public var updated: Date?

    /// This is a key-value map of Field name and value found on the Provider to which the credentials belongs to.
    public var fields: [String: String]

    /// A key-value structure to handle if status of credentials are `Credential.Status.awaitingSupplementalInformation`.
    internal var supplementalInformationFields: [Provider.FieldSpecification]

    public struct ThirdPartyAppAuthentication {
        public var downloadTitle: String
        public var downloadMessage: String
        public var upgradeTitle: String
        public var upgradeMessage: String
        public var appStoreURL: URL?
        public var scheme: String?
        public var deepLinkURL: URL?
    }

    public var thirdPartyAppAuthentication: ThirdPartyAppAuthentication?

    /// Indicates when the session of credentials with access type `Provider.AccessType.openBanking` will expire. After this date automatic refreshes will not be possible without new authentication from the user.
    public var sessionExpiryDate: Date?
}

public enum CredentialType: CustomStringConvertible {
    case unknown
    case password
    case mobileBankID
    case keyfob
    case fraud
    case thirdPartyAuthentication

    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .password:
            return "Password"
        case .mobileBankID:
            return "Mobile BankID"
        case .keyfob:
            return "Key Fob"
        case .fraud:
            return "Fraud"
        case .thirdPartyAuthentication:
            return "Third Party Authentication"
        }
    }
}

