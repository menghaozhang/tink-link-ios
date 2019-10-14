import Foundation
/// Access to user data is controlled by using OAuth2 security scopes or permissions. Each API customer is configured to have a set of scopes which control the maximum permitted data access.
public struct ScopeSet: OptionSet, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let read = ScopeSet(rawValue: 1 << 0)
    public static let write = ScopeSet(rawValue: 1 << 1)
    public static let grant = ScopeSet(rawValue: 1 << 2)
    public static let revoke = ScopeSet(rawValue: 1 << 3)
    public static let refresh = ScopeSet(rawValue: 1 << 4)
    public static let categorize = ScopeSet(rawValue: 1 << 5)
    public static let execute = ScopeSet(rawValue: 1 << 6)
    public static let create = ScopeSet(rawValue: 1 << 7)
    public static let delete = ScopeSet(rawValue: 1 << 8)
    public static let webHooks = ScopeSet(rawValue: 1 << 9)

    static var scopeDescriptions: [ScopeSet: String] = {
        var descriptions = [ScopeSet:String]()
        descriptions[.read] = "read"
        descriptions[.write] = "write"
        descriptions[.grant] = "grant"
        descriptions[.revoke] = "revoke"
        descriptions[.refresh] = "refresh"
        descriptions[.categorize] = "categorize"
        descriptions[.execute] = "execute"
        descriptions[.create] = "create"
        descriptions[.delete] = "delete"
        descriptions[.webHooks] = "web_hooks"
        return descriptions
    }()
}
