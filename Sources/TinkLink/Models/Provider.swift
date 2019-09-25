import Foundation

/// The provider model represents financial institutions to where Tink can connect. It specifies how Tink accesses the financial institution, metadata about the financialinstitution, and what financial information that can be accessed.
public struct Provider {
    /// The unique identifier of the provider.
    /// - Note: This is used when creating new credentials.
    public var name: Identifier<Provider>

    /// The display name of the provider.
    public var displayName: String

    /// Indicates what kind of financial institution the provider represents.
    public var type: ProviderType

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

    public var credentialType: CredentialType

    public var helpText: String

    /// Indicates if the provider is popular. This is normally set to true for the biggest financial institutions on a market.
    public var isPopular: Bool

    internal struct FieldSpecification {
        // description
        internal let fieldDescription: String
        /// Gray text in the input view (Similar to a placeholder)
        internal let hint: String
        internal let maxLength: Int?
        internal let minLength: Int?
        /// Controls whether or not the field should be shown masked, like a password field.
        internal let isMasked: Bool
        internal let isNumeric: Bool
        internal let isImmutable: Bool
        internal let isOptional: Bool
        internal let name: String
        internal let initialValue: String
        internal let pattern: String
        internal let patternError: String
        /// Text displayed next to the input field
        internal let helpText: String
    }

    internal var fields: [FieldSpecification]

    /// A display name for providers which are branches of a bigger group.
    public var groupDisplayName: String

    public var image: URL?

    /// Short displayable description of the authentication type used.
    public var displayDescription: String

    /// Indicates what a provider is capable of.
    public struct Capabilities: OptionSet, Hashable {
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

    public enum AccessType: CustomStringConvertible, Hashable {
        case unknown
        case openBanking
        case other

        public var description: String {
            switch self {
            case .unknown:
                return "Unknown"
            case .openBanking:
                return "Open Banking"
            case .other:
                return "Other"
            }
        }
        
        public static let all: Set<AccessType> = [.openBanking, .other, .unknown]
    }

    /// What Tink uses to access the data.
    public var accessType: AccessType

    /// The market of the provider.
    /// - Note: Each provider is unique per market.
    public var marketCode: String

    public var financialInstitutionID: String
    public var financialInstitutionName: String
}

public enum ProviderType {
    case unknown
    case bank
    case creditCard
    case broker
    case other
    case test
    case fraud
}

