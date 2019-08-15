public struct Identifier<Value>: Hashable, ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        rawValue = value
    }
    let rawValue: String
}
