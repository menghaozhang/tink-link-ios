import Foundation

/// The provider model represents financial institutions to where Tink can connect. It specifies how Tink accesses the financial institution, metadata about the financialinstitution, and what financial information that can be accessed.
public struct Provider {
    /// The unique identifier of the provider.
    /// - Note: This is used when creating new credentials.
    public var name: String

    /// The display name of the provider.
    public var displayName: String

    public enum `Type` {
        case unknown
        case bank
        case creditCard
        case broker
        case other
        case test
        case fraud
    }

    /// Indicates what kind of financial institution the provider represents.
    public var type: `Type`

    public enum Status {
        case unknown
        case enabled
        case disabled
        case temporaryDisabled
        case obsolete
    }
    
    /// Indicates the current status of the provider.
    /// - Note: It is only possible to perform credentials create or refresh actions on providers which are enabled.
    public var status: Status

    // TODO: var credentialType: Credential.`Type`

    public var helpText: String

    /// Indicates if the provider is popular. This is normally set to true for the biggest financial institutions on a market.
    public var isPopular: Bool

    public struct FieldSpecification {
        // description
        public var fieldDescription: String
        /// Gray text in the input view (Similar to a placeholder)
        public var hint: String
        public var maxLength: Int?
        public var minLength: Int?
        /// Controls whether or not the field should be shown masked, like a password field.
        public var isMasked: Bool
        public var isNumeric: Bool
        public var isImmutable: Bool
        public var isOptional: Bool
        public var name: String
        public var value: String
        public var pattern: String
        public var patternError: String
        /// Text displayed next to the input field
        public var helpText: String
    }

    public var fields: [FieldSpecification]

    /// A display name for providers which are branches of a bigger group.
    public var groupDisplayName: String

    public var image: URL?

    /// Short displayable description of the authentication type used.
    public var displayDescription: String

    /// Indicates what a provider is capable of.
    public struct Capabilities: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let transfers            = Capabilities(rawValue: 1 << 1)
        public static let mortgageAggregation  = Capabilities(rawValue: 1 << 2)
        public static let checkingAccounts     = Capabilities(rawValue: 1 << 3)
        public static let savingsAccounts      = Capabilities(rawValue: 1 << 4)
        public static let creditCards          = Capabilities(rawValue: 1 << 5)
        public static let investments          = Capabilities(rawValue: 1 << 6)
        public static let loans                = Capabilities(rawValue: 1 << 7)
        public static let payments             = Capabilities(rawValue: 1 << 8)
        public static let mortgageLoan         = Capabilities(rawValue: 1 << 9)
        public static let identityData         = Capabilities(rawValue: 1 << 10)

        public static let all: Capabilities = [.transfers, .mortgageAggregation, .checkingAccounts, .savingsAccounts, .creditCards, .investments, .loans, .payments, .mortgageLoan, .identityData]
    }

    /// Indicates what this provider is capable of, in terms of financial data it can aggregate and if it can execute payments.
    public var capabilities: Capabilities

    public enum AccessType {
        case unknown
        case openBanking
        case other
    }

    /// What Tink uses to access the data.
    public var accessType: AccessType

    /// The market of the provider.
    /// - Note: Each provider is unique per market.
    public var marketCode: String

    public var financialInstitutionID: String
    public var financialInstitutionName: String
}
