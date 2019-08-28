public struct AccessToken: Hashable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ value: String) {
        self.rawValue = value
    }
}
