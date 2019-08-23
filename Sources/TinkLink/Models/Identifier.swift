public struct Identifier<Value>: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        rawValue = value
    }

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public let rawValue: String
}
