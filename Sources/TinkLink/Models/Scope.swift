import Foundation
public protocol ScopeType: CustomStringConvertible {
    static var name: String { get set }
}

/// Access to Tink is divided into scopes. The available scopes for Tink's APIs can be found in Tink console
extension TinkLink {
    public struct Scope: CustomStringConvertible {
        enum Access: String {
            case read, write, grant, revoke, refresh, categorize, execute, create, delete, webHooks
        }
        
        /// Access to all the user's account information, including balances.
        public struct Accounts: ScopeType {
            public static var name = "accounts"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        public struct Activities: ScopeType {
            public static var name = "activities"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        public struct Authorization: ScopeType {
            public static var name = "authorization"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var grant = Self(access: .grant)
            public static var revoke = Self(access: .revoke)
        }

        public struct Budgets: ScopeType {
            public static var name = "budgets"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        public struct Calendar: ScopeType {
            public static var name = "calendar"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        public struct Categories: ScopeType {
            public static var name = "categories"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        public struct Contacts: ScopeType {
            public static var name = "contacts"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        /// Access to the information describing the user's different bank credentials connected to Tink.
        public struct Credentials: ScopeType {
            public static var name = "credentials"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
            public static var refresh = Self(access: .refresh)
        }

        public struct DataExports: ScopeType {
            public static var name = "data-exports"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        public struct Documents: ScopeType {
            public static var name = "documents"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        public struct Follow: ScopeType {
            public static var name = "follow"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        /// Access to the user's personal information that can be used for identification purposes.
        public struct Identity: ScopeType {
            public static var name = "identity"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        public struct Insights: ScopeType {
            public static var name = "insights"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        /// Access to the user's portfolios and underlying financial instruments.
        public struct Investments: ScopeType {
            public static var name = "investments"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        public struct Payment: ScopeType {
            public static var name = "payment"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        public struct Properties: ScopeType {
            public static var name = "properties"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
        }

        public struct Providers: ScopeType {
            public static var name = "providers"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        /// Access to all the user's statistics, which can include filters on statistic.type.
        public struct Statistics: ScopeType {
            public static var name = "statistics"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        public struct Suggestions: ScopeType {
            public static var name = "suggestions"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
        }

        /// Access to all the user's transactional data.
        public struct Transactions: ScopeType {
            public static var name = "transactions"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
            public static var categorize = Self(access: .categorize)
        }

        public struct Transfer: ScopeType {
            public static var name = "transfer"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var execute = Self(access: .execute)
        }

        /// Access to user profile data such as e-mail, date of birth, etc.
        public struct User: ScopeType {
            public static var name = "user"
            public var description: String {
                return Self.name + ":" + access.rawValue
            }
            private var access: TinkLink.Scope.Access

            public static var read = Self(access: .read)
            public static var write = Self(access: .write)
            public static var create = Self(access: .create)
            public static var delete = Self(access: .delete)
            public static var webHooks = Self(access: .webHooks)
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

