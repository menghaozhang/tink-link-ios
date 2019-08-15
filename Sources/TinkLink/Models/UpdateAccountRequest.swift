public struct UpdateAccountRequest {
    enum AccountOwnership: Double {
        case owned = 1
        case shared = 0.5
    }
    
    var accountID: String
    var accountName: String
    var accountType: GRPCAccount.TypeEnum
    var accountFavored: Bool
    var accountExcluded: Bool
    var accountOwnership: AccountOwnership
}
