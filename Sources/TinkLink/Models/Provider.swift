/// The provider model represents financial institutions to where Tink can connect. It specifies how Tink accesses the financial institution, metadata about the financialinstitution, and what financial information that can be accessed.
public struct Provider {
    /// The unique identifier of the provider.
    /// - Note: This is used when creating new credentials.
    var name: String

    /// The display name of the provider.
    var displayName: String

    enum `Type` {
        case unknown
        case bank
        case creditCard
        case broker
        case other
        case test
        case fraud
    }

    /// Indicates what kind of financial institution the provider represents.
    var type: `Type`

    enum Status {
        case unknown
        case enabled
        case disabled
        case temporaryDisabled
        case obsolete
    }
    
    /// Indicates the current status of the provider.
    /// - Note: It is only possible to perform credentials create or refresh actions on providers which are enabled.
    var status: Status

    // TODO: var credentialType: Credential.`Type`

    var helpText: String

    /// Indicates if the provider is popular. This is normally set to true for the biggest financial institutions on a market.
    var isPopular: Bool

    struct FieldSpecification {
        // TODO:
    }

    var fields: [FieldSpecification]

    /// A display name for providers which are branches of a bigger group.
    var groupDisplayName: String

    var image: URL?

    /// Short displayable description of the authentication type used.
    var displayDescription: String

    /// Indicates what a provider is capable of.
    public struct Capabilities: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let transfers            = Capabilities(rawValue: 1 << 1)
        static let mortgageAggregation  = Capabilities(rawValue: 1 << 2)
        static let checkingAccounts     = Capabilities(rawValue: 1 << 3)
        static let savingsAccounts      = Capabilities(rawValue: 1 << 4)
        static let creditCards          = Capabilities(rawValue: 1 << 5)
        static let investments          = Capabilities(rawValue: 1 << 6)
        static let loans                = Capabilities(rawValue: 1 << 7)
        static let payments             = Capabilities(rawValue: 1 << 8)
        static let mortgageLoan         = Capabilities(rawValue: 1 << 9)
        static let identityData         = Capabilities(rawValue: 1 << 10)
    }

    /// Indicates what this provider is capable of, in terms of financial data it can aggregate and if it can execute payments.
    var capabilities: Capabilities

    enum AccessType {
        case unknown
        case openBanking
        case other
    }

    /// What Tink uses to access the data.
    var accessType: AccessType

    /// The market of the provider.
    /// - Note: Each provider is unique per market.
    var marketCode: String

    var financialInstitutionID: String
    var financialInstitutionName: String
}
