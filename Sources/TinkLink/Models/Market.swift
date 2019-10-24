import Foundation

/// Represents a market by a two-letter country code.
///
/// ISO 3166-1 alpha-2
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

    /// A two-letter country code.
    public var code: String {
        return rawValue
    }

    /// Returns a localized string for a specified region code.
    ///
    /// For example, in the “en” locale, the result for "SE" is "Sweden".
    public var localizedString: String? {
        return Locale.current.localizedString(forRegionCode: code)
    }

    /// The default market that is used. 
    public static var defaultMarket: Market {
        return Market(code: "SE")
    }
}

extension Market: Comparable {
    public static func < (lhs: Market, rhs: Market) -> Bool {
        return (lhs.localizedString ?? lhs.code).caseInsensitiveCompare(rhs.localizedString ?? rhs.code) == .orderedAscending
    }
}

extension TinkLink {
    public static var defaultMarket: Market {
        return .defaultMarket
    }
}
