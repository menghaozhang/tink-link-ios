import Foundation
public protocol ScopeType: CustomStringConvertible {
    static var name: String { get set }
    var scope: TinkLink.Access { get set }
}

extension ScopeType {
    public var description: String {
        return scope.descriptions.map { Self.name + ":" + $0 }.joined(separator: ",")
    }
}

/// Access to Tink is divided into scopes. The available scopes for Tink's APIs can be found in Tink console
extension TinkLink {
    public struct Scope: CustomStringConvertible {
        /// Access to all the user's account information, including balances.
        public struct Accounts: ScopeType {
            public static var name = "accounts"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Activities: ScopeType {
            public static var name = "activities"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Authorization: ScopeType {
            public static var name = "authorization"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Budgets: ScopeType {
            public static var name = "budgets"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Calendar: ScopeType {
            public static var name = "calendar"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Categories: ScopeType {
            public static var name = "categories"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Contacts: ScopeType {
            public static var name = "contacts"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        /// Access to the information describing the user's different bank credentials connected to Tink.
        public struct Credentials: ScopeType {
            public static var name = "credentials"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct DataExports: ScopeType {
            public static var name = "data-exports"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Documents: ScopeType {
            public static var name = "documents"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Follow: ScopeType {
            public static var name = "follow"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        /// Access to the user's personal information that can be used for identification purposes.
        public struct Identity: ScopeType {
            public static var name = "identity"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Insights: ScopeType {
            public static var name = "insights"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        /// Access to the user's portfolios and underlying financial instruments.
        public struct Investments: ScopeType {
            public static var name = "investments"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Payment: ScopeType {
            public static var name = "payment"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Properties: ScopeType {
            public static var name = "properties"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Providers: ScopeType {
            public static var name = "providers"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        /// Access to all the user's statistics, which can include filters on statistic.type.
        public struct Statistics: ScopeType {
            public static var name = "statistics"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Suggestions: ScopeType {
            public static var name = "suggestions"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }
        /// Access to all the user's transactional data.
        public struct Transactions: ScopeType {
            public static var name = "transactions"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public struct Transfer: ScopeType {
            public static var name = "transfer"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        /// Access to user profile data such as e-mail, date of birth, etc.
        public struct User: ScopeType {
            public static var name = "user"
            public var scope: TinkLink.Access
            public init(_ scope: TinkLink.Access) {
                self.scope = scope
            }
        }

        public var scopes: [ScopeType]
        public var description: String
        public init(scopes: [ScopeType]) {
            precondition(!scopes.isEmpty, "Tinklink scope is empty.")
            self.scopes = scopes

            description = scopes.map({ $0.description }).joined(separator: ",")
        }
    }
}

