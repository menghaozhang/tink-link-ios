/// Request used to update the account
public struct UpdateAccountRequest {
    enum AccountOwnership: Double {
        case owned = 1
        case shared = 0.5
    }
    
    /// The identifier of account.
    var accountID: String
    
    /// The display name of the account.
    var accountName: String
    
    /// The type of the account.
    /// - Possible values: `checking`, `savings`, `investment`, `mortgage`, `credit_card`, `loan`, `pension`, `other`, `external`
    var accountType: GRPCAccount.TypeEnum
    
    /// Indicates if the user has favored the account.
    var accountFavored: Bool
    
    /// Indicates if the user has excluded the account.
    var accountExcluded: Bool
    
    /// The ownership ratio indicating how much of the account is owned by the user.
    /// The ownership determine the percentage of the amounts on transactions belonging to this account, that should be attributed to the user when statistics are calculated.
    var accountOwnership: AccountOwnership
}
