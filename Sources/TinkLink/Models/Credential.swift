import Foundation

/// The credentials model represents users connected providers from where financial data is accessed.
public struct Credential {
    public struct Identifier: Hashable, RawRepresentable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            rawValue = value
        }

        public init?(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ value: String) {
            self.rawValue = value
        }

        public let rawValue: String
    }

    /// The unique identifier of the credentials.
    public var id: Identifier

    /// The provider (financial institution) that the credentials is connected to.
    public var providerName: Provider.Identifier

    /// Indicates how Tink authenticates the user to the financial institution.
    public var type: CredentialType

    public enum Status {
        case unknown
        case created
        case authenticating
        case updating
        case updated
        case temporaryError
        case authenticationError
        case permanentError
        /// Will be deprecated and replaced with `awaitingThirdPartyAppAuthentication`
        case awaitingMobileBankIDAuthentication
        case awaitingSupplementalInformation
        case disabled
        case awaitingThirdPartyAppAuthentication
        case sessionExpired
    }

    /// The status indicates the state of the credentials. For some states there are actions which need to be performed on the credentials.
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

