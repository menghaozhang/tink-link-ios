import Foundation

/// An account could either be a debit account, a credit card, a loan or mortgage.
public struct Account {
    public enum `Type` {
        case unknown
        case checking
        case savings
        case investment
        case mortgage
        case creditCard
        case loan
        case dummy
        case pension
        case other
        case external
    }
    
    public enum Exclusion {
        case unkown
        case aggregation
        case pfmAndSearch
        case pfmData
        case none
    }
    
    public struct Flag: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let business = Flag(rawValue: 1 << 1)
        public static let mandate = Flag(rawValue: 1 << 2)
    }

    /// The internal identifier of account.
    public var id: Identifier<Account>

    /// The current balance of the account.
    ///
    /// The definition of the balance property differ between account types.
    /// - `savings`: The balance represent the actual amount of cash in the account,
    /// - `investment`: The balance represents the value of the investments connected to this accounts including any available cash,
    /// - `mortgage`: The balance represents the loan debt outstanding from this account,
    /// - `creditCard`: the balance represent the outstanding balance on the account, it does not include any available credit or purchasing power the user has with the credit provider.
    public var balance: CurrencyDenominatedAmount

    /// The type of the account.
    ///
    /// - Note: This property can be updated in a update account request.
    public var type: Account.`Type`

    /// The account number of the account.
    ///
    /// The format of the account numbers may differ between account types and banks.
    public var accountNumber: String

    /// The internal identifier of the credentials that the account belongs to.
    public var credentialID: Identifier<Credential>

    /// Indicates if the user has excluded the account.
    ///
    /// If `true` Categorization and PFM Features are excluded, and transactions belonging to this account are not searchable.
    ///
    /// - Note: This property can be updated in a update account request.
    public var isExcluded: Bool
    
    /// Indicates if the user has favored the account.
    ///
    /// - Note: This property can be updated in a update account request.
    public var isFavored: Bool

    public var isTransactional: Bool

    /// The display name of the account.
    ///
    /// - Note: This property can be updated in a update account request.
    public var name: String

    /// The ownership ratio indicating how much of the account is owned by the user.
    ///
    /// The ownership determine the percentage of the amounts on transactions belonging to this account, that should be attributed to the user when statistics are calculated.
    ///
    /// - Note: This property can be updated in a update account request.
    public var ownership: Double

    /// A closed account indicates that it was no longer available from the connected financial institution, most likely due to it having been closed by the user.
    public var isClosed: Bool

    /// Indicate features this account should be excluded from.
    ///
    /// Possible values are:
    /// - `none`: No features are excluded from this account,
    /// - `pfmData`: Categorization and Personal Finance Management Features, like statistics and activities are excluded,
    /// - `pfmAndSearch`: Categorization and Personal Finance Management Features are excluded, and transactions belonging to this account are not searchable. This is the equivalent of the, now deprecated, boolean flag 'excluded',
    /// - `aggregation`: No data will be aggregated for this account and, all data associated with the account is removed (except account name and account number).
    ///
    /// - Note: This property can be updated in a update account request.
    public var exclusionType: Account.Exclusion

    /// A list of flags specifying attributes on an account.
    public var flags: Account.Flag

    public var images: URL?
}
