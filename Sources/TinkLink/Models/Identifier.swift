public struct Identifier<Value>: Hashable, ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        rawValue = value
    }
    let rawValue: String
}
