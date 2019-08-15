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
    
    public enum AccountFlag {
        case unknown
        case business
        case mandate
    }
    
    public enum AccountOwnership: Double {
        case owned = 1
        case shared = 0.5
    }
    
    
    public var id: Identifier<Account>
    // TODO:    public var balance:
    public var type: Account.`Type`
    public var accountNumber: String
    public var credentialID: String // TODO: Identifier<Credential>
    public var excluded: Bool
    public var favored: Bool
    public var transactional: Bool
    public var name: String
    public var ownership: AccountOwnership
    public var closed: Bool
    public var exclusionType: Account.Exclusion
    public var flags: [Account.AccountFlag]
    // TODO: public var images: Images
}
