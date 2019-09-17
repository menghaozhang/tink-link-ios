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

public extension Market {
    static var defaultMarket: Market {
        return Market(code: "SE")
    }
}

extension Market: Comparable {
    public static func < (lhs: Market, rhs: Market) -> Bool {
        return (lhs.localizedString ?? lhs.code).caseInsensitiveCompare(rhs.localizedString ?? rhs.code) == .orderedAscending
    }
}

extension Array where Element == Market {
    public func sortedWithCurrentRegionFirst() -> [Market] {
        var sortedMarkets = sorted()
        if let currentRegionCode = Locale.current.regionCode, let index = sortedMarkets.firstIndex(of: Market(code: currentRegionCode)) {
            let currentMarket = sortedMarkets.remove(at: index)
            sortedMarkets.insert(currentMarket, at: 0)
        }
        return sortedMarkets
    }
}
