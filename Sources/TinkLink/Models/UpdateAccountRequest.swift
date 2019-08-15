/// Request used to update the account
public struct UpdateAccountRequest {
    
    /// The identifier of account.
    public var accountID: Identifier<Account>
    
    /// The display name of the account.
    public var accountName: String
    
    /// The type of the account.
    /// - Possible values: `checking`, `savings`, `investment`, `mortgage`, `credit_card`, `loan`, `pension`, `other`, `external`
    public var accountType: Account.`Type`
    
    /// Indicates if the user has favored the account.
    public var accountFavored: Bool
    
    /// Indicates if the user has excluded the account.
    public var accountExcluded: Bool
    
    /// The ownership ratio indicating how much of the account is owned by the user.
    /// The ownership determine the percentage of the amounts on transactions belonging to this account, that should be attributed to the user when statistics are calculated.
    public var accountOwnership: Account.AccountOwnership
}

extension UpdateAccountRequest {
    public init(account: Account) {
        accountID = account.id
        accountName = account.name
        accountType = account.type
        accountFavored = account.favored
        accountExcluded = account.excluded
        accountOwnership = account.ownership
    }
}
