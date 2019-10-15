/// The FinancialInstitution model represents a financial institution.
public struct FinancialInstitution: Hashable {
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(_ value: String) {
            self.value = value
        }

        public let value: String
    }

    /// A unique identifier.
    ///
    /// Use this to group providers belonging the same financial institution.
    public var id: ID

    /// The name of the financial institution.
    public var name: String
}
