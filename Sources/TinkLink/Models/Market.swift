public struct Market: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init(code value: String) {
        self.rawValue = value
    }

    public var code: String {
        return rawValue
    }
}
