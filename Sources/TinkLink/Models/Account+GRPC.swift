extension Account.`Type` {
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
