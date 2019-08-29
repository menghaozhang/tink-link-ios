/// Request used to update the account
public struct UpdateAccountRequest {
    
    /// The identifier of account.
    public var id: Identifier<Account>
    
    /// The display name of the account.
    public var name: String
    
    /// The type of the account.
    /// - Possible values: `checking`, `savings`, `investment`, `mortgage`, `credit_card`, `loan`, `pension`, `other`, `external`
    public var type: Account.`Type`
    
    /// Indicates if the user has favored the account.
    public var isFavored: Bool
    
    /// Indicates if the user has excluded the account.
    public var isExcluded: Bool
    
    /// The ownership ratio indicating how much of the account is owned by the user.
    /// The ownership determine the percentage of the amounts on transactions belonging to this account, that should be attributed to the user when statistics are calculated.
    public var ownership: Double
}

extension UpdateAccountRequest {
    public init(account: Account) {
        id = account.id
        name = account.name
        type = account.type
        isFavored = account.isFavored
        isExcluded = account.isExcluded
        ownership = account.ownership
    }
}
