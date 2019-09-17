/// Request used to update the account
struct UpdateAccountRequest {
    
    /// The identifier of account.
    var id: Identifier<Account>
    
    /// The display name of the account.
    var name: String
    
    /// The type of the account.
    /// - Possible values: `checking`, `savings`, `investment`, `mortgage`, `credit_card`, `loan`, `pension`, `other`, `external`
    var type: Account.`Type`
    
    /// Indicates if the user has favored the account.
    var isFavored: Bool
    
    /// Indicates if the user has excluded the account.
    var isExcluded: Bool
    
    /// The ownership ratio indicating how much of the account is owned by the user.
    /// The ownership determine the percentage of the amounts on transactions belonging to this account, that should be attributed to the user when statistics are calculated.
    var ownership: Double
}

extension UpdateAccountRequest {
    init(account: Account) {
        id = account.id
        name = account.name
        type = account.type
        isFavored = account.isFavored
        isExcluded = account.isExcluded
        ownership = account.ownership
    }
}
