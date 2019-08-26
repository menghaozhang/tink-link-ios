import Foundation

extension Account {
    init(grpcAccount: GRPCAccount) {
        self.id = .init(grpcAccount.id)
        self.accountNumber = grpcAccount.accountNumber
        self.name = grpcAccount.name
        self.credentialID = .init(grpcAccount.credentialID)
        self.isExcluded = grpcAccount.excluded
        self.exclusionType = Account.Exclusion(grpcAccountExclustion: grpcAccount.exclusionType)
        self.isFavored = grpcAccount.favored
        self.isClosed = grpcAccount.closed
        self.isTransactional = grpcAccount.transactional
        self.flags = Account.Flags(grpcAccountFlags: grpcAccount.flags)
        self.ownership = grpcAccount.ownership.doubleValue
        self.type = `Type`(grpcAccountType: grpcAccount.type)
        self.balance = CurrencyDenominatedAmount(grpcCurrencyDenominatedAmount: grpcAccount.balance)
        self.images = URL(string: grpcAccount.images.iconURL)
    }
}

extension Account.Exclusion {
    init(grpcAccountExclustion: GRPCAccount.Exclusion) {
        switch grpcAccountExclustion {
        case .unkown, .UNRECOGNIZED:
            self = .unkown
        case .aggregation:
            self = .aggregation
        case .pfmAndSearch:
            self = .pfmAndSearch
        case .pfmData:
            self = .pfmData
        case .none:
            self = .none
        }
    }
}

extension Account.Flags {
    init(grpcAccountFlags: [GRPCAccount.AccountFlag]) {
        self = grpcAccountFlags.reduce([], { (flag, grpcAccountFlag) in
            switch grpcAccountFlag {
            case .unknown:
                return flag
            case .business:
                return flag.union(.business)
            case .mandate:
                return flag.union(.mandate)
            case .UNRECOGNIZED(let value):
                assertionFailure("Unrecognized flag: \(value)")
                return flag
            }
        })
    }
}

extension Account.`Type` {
    init(grpcAccountType: GRPCAccount.TypeEnum) {
        switch grpcAccountType {
        case .unknown, .UNRECOGNIZED:
            self = .unknown
        case .checking:
            self = .checking
        case .savings:
            self = .savings
        case .investment:
            self = .investment
        case .mortgage:
            self = .mortgage
        case .creditCard:
            self = .creditCard
        case .loan:
            self = .loan
        case .dummy:
            self = .dummy
        case .pension:
            self = .pension
        case .other:
            self = .other
        case .external:
            self = .external
        }
    }
    var grpcType: GRPCAccount.TypeEnum {
        switch self {
        case .unknown:
            return .unknown
        case .checking:
            return .checking
        case .savings:
            return .savings
        case .investment:
            return .investment
        case .mortgage:
            return .mortgage
        case .creditCard:
            return .creditCard
        case .loan:
            return .loan
        case .dummy:
            return .dummy
        case .pension:
            return .pension
        case .other:
            return .other
        case .external:
            return .external
        }
    }
}