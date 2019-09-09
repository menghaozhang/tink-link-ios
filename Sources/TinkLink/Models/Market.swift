import Foundation

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

    public var localizedString: String? {
        return Locale.current.localizedString(forRegionCode: code)
    }
}

extension Market: Comparable {
    public static func < (lhs: Market, rhs: Market) -> Bool {
        return (lhs.localizedString ?? lhs.code).caseInsensitiveCompare(rhs.localizedString ?? rhs.code) == .orderedAscending
    }
}
