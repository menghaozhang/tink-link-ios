import Foundation
public protocol ScopeType: CustomStringConvertible {
    static var name: String { get set }
    var access: TinkLink.Scope.Access { get set }
}

extension ScopeType {
    public var description: String {
        return access.descriptions.map { Self.name + ":" + $0 }.joined(separator: ",")
    }
}

/// Access to Tink is divided into scopes. The available scopes for Tink's APIs can be found in Tink console
extension TinkLink {
    public struct Scope: CustomStringConvertible {
        /// Access to all the user's account information, including balances.
        public struct Accounts: ScopeType {
            public static var name = "accounts"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Activities: ScopeType {
            public static var name = "activities"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Authorization: ScopeType {
            public static var name = "authorization"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Budgets: ScopeType {
            public static var name = "budgets"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Calendar: ScopeType {
            public static var name = "calendar"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Categories: ScopeType {
            public static var name = "categories"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Contacts: ScopeType {
            public static var name = "contacts"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        /// Access to the information describing the user's different bank credentials connected to Tink.
        public struct Credentials: ScopeType {
            public static var name = "credentials"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct DataExports: ScopeType {
            public static var name = "data-exports"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Documents: ScopeType {
            public static var name = "documents"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Follow: ScopeType {
            public static var name = "follow"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        /// Access to the user's personal information that can be used for identification purposes.
        public struct Identity: ScopeType {
            public static var name = "identity"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Insights: ScopeType {
            public static var name = "insights"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        /// Access to the user's portfolios and underlying financial instruments.
        public struct Investments: ScopeType {
            public static var name = "investments"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Payment: ScopeType {
            public static var name = "payment"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Properties: ScopeType {
            public static var name = "properties"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Providers: ScopeType {
            public static var name = "providers"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        /// Access to all the user's statistics, which can include filters on statistic.type.
        public struct Statistics: ScopeType {
            public static var name = "statistics"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Suggestions: ScopeType {
            public static var name = "suggestions"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }
        /// Access to all the user's transactional data.
        public struct Transactions: ScopeType {
            public static var name = "transactions"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        public struct Transfer: ScopeType {
            public static var name = "transfer"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
            }
        }

        /// Access to user profile data such as e-mail, date of birth, etc.
        public struct User: ScopeType {
            public static var name = "user"
            public var access: TinkLink.Scope.Access
            public init(_ access: TinkLink.Scope.Access) {
                self.access = access
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

