struct AccessToken: Hashable, RawRepresentable {
    let rawValue: String

    init?(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ value: String) {
        self.rawValue = value
    }
}
