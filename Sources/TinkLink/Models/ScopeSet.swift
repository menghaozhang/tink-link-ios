import Foundation
public struct ScopeSet: OptionSet, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let read = ScopeSet(rawValue: 1 << 0)
    static let write = ScopeSet(rawValue: 1 << 1)
    static let grant = ScopeSet(rawValue: 1 << 2)
    static let revoke = ScopeSet(rawValue: 1 << 3)
    static let refresh = ScopeSet(rawValue: 1 << 4)
    static let categorize = ScopeSet(rawValue: 1 << 5)
    static let execute = ScopeSet(rawValue: 1 << 6)
    static let create = ScopeSet(rawValue: 1 << 7)
    static let delete = ScopeSet(rawValue: 1 << 8)
    static let webHooks = ScopeSet(rawValue: 1 << 9)

    static var scopeDescriptions: [ScopeSet: String] = {
        var descriptions = [ScopeSet:String]()
        descriptions[.read] = "read"
        descriptions[.write] = "write"
        descriptions[.grant] = "grant"
        descriptions[.revoke] = "revoke"
        descriptions[.refresh] = "refresh"
        descriptions[.categorize] = "categorize"
        descriptions[.grant] = "grant"
        descriptions[.grant] = "grant"
        return descriptions
    }()
}


public protocol ScopeType: CustomStringConvertible {
    static var name: String { get set }
    var scope: ScopeSet { get set }
}

extension ScopeType {
    public var description: String {
        var scopes = [String]()
        for (scopeKey, scopeString) in ScopeSet.scopeDescriptions {
            if scope.contains(scopeKey) {
                scopes.append(AccountsScope.name + scopeString)
            }
        }
        return scopes.joined(separator: ",")
    }
}

public struct AccountsScope: ScopeType {
    public static var name = "accounts:"
    public var scope: ScopeSet
}

public struct ActivitiesScope: ScopeType {
    public static var name = "activities:"
    public var scope: ScopeSet
}

public struct AuthorizationScope: ScopeType {
    public static var name = "authorization:"
    public var scope: ScopeSet
}

public struct TinkLinkScope: CustomStringConvertible {
    public var scopes: [ScopeType]
    public var description: String
    public init(accountsScope: AccountsScope?, activitiesScope: ActivitiesScope?, authorizationScope: AuthorizationScope?) {
        scopes = []
        if let accountsScope = accountsScope {
            scopes.append(accountsScope)
        }

        description = scopes.map { $0.description }.joined(separator: ",")
    }
}
