/// An amount represented as a scale and unscaled value together with the ISO 4217 currency code of the amount.
public struct CurrencyDenominatedAmount {
    /// Amount represented as a scale and unscaled value together.
    public var value: ExactNumber
    /// The ISO 4217 currency code of the amount.
    public var currencyCode: String
}
