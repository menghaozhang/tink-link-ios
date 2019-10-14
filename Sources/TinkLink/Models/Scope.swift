import Foundation

public protocol ScopeType: CustomStringConvertible {
    static var name: String { get set }
    var scope: ScopeSet { get set }
}

extension ScopeType {
    public var description: String {
        var scopes = [String]()
        for (scopeKey, scopeString) in ScopeSet.scopeDescriptions {
            if scope.contains(scopeKey) {
                scopes.append(Self.name + scopeString)
            }
        }
        return scopes.joined(separator: ",")
    }
}

/// Access to all the user's account information, including balances.
public struct AccountsScope: ScopeType {
    public static var name = "accounts:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct ActivitiesScope: ScopeType {
    public static var name = "activities:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct AuthorizationScope: ScopeType {
    public static var name = "authorization:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct BudgetsScope: ScopeType {
    public static var name = "budgets:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct CalendarScope: ScopeType {
    public static var name = "calendar:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct CategoriesScope: ScopeType {
    public static var name = "categories:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct ContactsScope: ScopeType {
    public static var name = "contacts:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

/// Access to the information describing the user's different bank credentials connected to Tink.
public struct CredentialsScope: ScopeType {
    public static var name = "credentials:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct DataExportsScope: ScopeType {
    public static var name = "data-exports:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct DocumentsScope: ScopeType {
    public static var name = "documents:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct FollowScope: ScopeType {
    public static var name = "follow:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

/// Access to the user's personal information that can be used for identification purposes.
public struct IdentityScope: ScopeType {
    public static var name = "identity:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct InsightsScope: ScopeType {
    public static var name = "insights:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

/// Access to the user's portfolios and underlying financial instruments.
public struct InvestmentsScope: ScopeType {
    public static var name = "investments:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct PaymentScope: ScopeType {
    public static var name = "payment:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct PropertiesScope: ScopeType {
    public static var name = "properties:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct ProvidersScope: ScopeType {
    public static var name = "providers:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

/// Access to all the user's statistics, which can include filters on statistic.type.
public struct StatisticsScope: ScopeType {
    public static var name = "statistics:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct SuggestionsScope: ScopeType {
    public static var name = "suggestions:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}
/// Access to all the user's transactional data.
public struct TransactionsScope: ScopeType {
    public static var name = "transactions:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

public struct TransferScope: ScopeType {
    public static var name = "transfer:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}

/// Access to user profile data such as e-mail, date of birth, etc.
public struct UserScope: ScopeType {
    public static var name = "user:"
    public var scope: ScopeSet
    public init(_ scope: ScopeSet) {
        self.scope = scope
    }
}
