/// The FinancialInstitution model represents a financial institution.
public struct FinancialInstitution: Hashable {
    /// A unique identifier.
    ///
    /// Use this to group providers belonging the same financial institution.
    public var id: String

    /// The name of the financial institution.
    public var name: String
}
