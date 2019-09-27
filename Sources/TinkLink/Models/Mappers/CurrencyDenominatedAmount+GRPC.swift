extension CurrencyDenominatedAmount {
    init(grpcCurrencyDenominatedAmount: GRPCCurrencyDenominatedAmount) {
        currencyCode = grpcCurrencyDenominatedAmount.currencyCode
        value = ExactNumber(value: grpcCurrencyDenominatedAmount.value)
    }
}
