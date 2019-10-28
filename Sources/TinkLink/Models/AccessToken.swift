struct AccessToken: Hashable, RawRepresentable, Decodable {
    let rawValue: String

    init?(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ value: String) {
        self.rawValue = value
    }
}
