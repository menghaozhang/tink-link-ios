import Foundation

/// Access to Tink is divided into scopes. The available scopes for Tink's APIs can be found in Tink console
public struct TinkLinkScope: CustomStringConvertible {
    public var scopes: [ScopeType]
    public var description: String
    public init(scopes: [ScopeType]) {
        precondition(!scopes.isEmpty, "Tinklink scope is empty.")
        self.scopes = scopes

        description = scopes.map({ $0.description }).joined(separator: ",")
    }
}
