import Foundation

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
    
    public enum Flag {
        case unknown
        case business
        case mandate
    }
    
    
    public var id: Identifier<Account>
    public var balance: CurrencyDenominatedAmount
    public var type: Account.`Type`
    public var accountNumber: String
    public var credentialID: String // TODO: Identifier<Credential>
    public var isExcluded: Bool
    public var isFavored: Bool
    public var isTransactional: Bool
    public var name: String
    public var ownership: Double
    public var isClosed: Bool
    public var exclusionType: Account.Exclusion
    public var flags: [Account.Flag]
    public var images: URL?
}
