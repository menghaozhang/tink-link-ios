extension Account {
    init(grpcAccount: GRPCAccount) {
        self.id = Identifier(stringLiteral: grpcAccount.id)
        self.accountNumber = grpcAccount.accountNumber
        self.name = grpcAccount.name
        // TODO:       grpcAccount.balance
        self.credentialID = grpcAccount.credentialID
        self.excluded = grpcAccount.excluded
        self.exclusionType = Account.Exclusion(grpcAccountExclustion: grpcAccount.exclusionType)
        self.favored = grpcAccount.favored
        self.closed = grpcAccount.closed
        self.transactional = grpcAccount.transactional
        self.flags = grpcAccount.flags.map({ Account.Flag(grpcAccountFlag: $0) })
        self.ownership = ExactNumber(value: grpcAccount.ownership)
        self.type = `Type`(grpcAccountType: grpcAccount.type)
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

extension Account.Flag {
    init(grpcAccountFlag: GRPCAccount.AccountFlag) {
        switch grpcAccountFlag {
        case .unknown, .UNRECOGNIZED:
            self = .unknown
        case .business:
            self = .business
        case .mandate:
            self = .mandate
        }
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
    var toGRPCType: GRPCAccount.TypeEnum {
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
