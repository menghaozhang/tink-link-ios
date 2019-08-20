public struct CurrencyDenominatedAmount {
    var value: ExactNumber
    var currencyCode: String
}

extension CurrencyDenominatedAmount {
    init(grpcCurrencyDenominatedAmount: GRPCCurrencyDenominatedAmount) {
        currencyCode = grpcCurrencyDenominatedAmount.currencyCode
        value = ExactNumber(value: grpcCurrencyDenominatedAmount.value)
    }
}
