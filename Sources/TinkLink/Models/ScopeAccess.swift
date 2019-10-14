import Foundation
/// Access to user data is controlled by using OAuth2 security scopes or permissions. Each API customer is configured to have a set of scopes which control the maximum permitted data access.
extension TinkLink.Scope {
//    enum Access: String {
//        case read, write, grant, revoke, refresh, categorize, execute, create, delete, webHooks
//    }
//    struct Access: OptionSet, Hashable {
//        let rawValue: Int
//        init(rawValue: Int) {
//            self.rawValue = rawValue
//        }
//
//        static let read = TinkLink.Scope.Access(rawValue: 1 << 0)
//        static let write = TinkLink.Scope.Access(rawValue: 1 << 1)
//        static let grant = TinkLink.Scope.Access(rawValue: 1 << 2)
//        static let revoke = TinkLink.Scope.Access(rawValue: 1 << 3)
//        static let refresh = TinkLink.Scope.Access(rawValue: 1 << 4)
//        static let categorize = TinkLink.Scope.Access(rawValue: 1 << 5)
//        static let execute = TinkLink.Scope.Access(rawValue: 1 << 6)
//        static let create = TinkLink.Scope.Access(rawValue: 1 << 7)
//        static let delete = TinkLink.Scope.Access(rawValue: 1 << 8)
//        static let webHooks = TinkLink.Scope.Access(rawValue: 1 << 9)
//
//        var descriptions: [String] {
//            var descriptionStrings = [String]()
//            if contains(.read) {
//                descriptionStrings.append("read")
//            }
//            if contains(.write) {
//                descriptionStrings.append("write")
//            }
//            if contains(.grant) {
//                descriptionStrings.append("grant")
//            }
//            if contains(.revoke) {
//                descriptionStrings.append("revoke")
//            }
//            if contains(.refresh) {
//                descriptionStrings.append("refresh")
//            }
//            if contains(.categorize) {
//                descriptionStrings.append("categorize")
//            }
//            if contains(.execute) {
//                descriptionStrings.append("execute")
//            }
//            if contains(.create) {
//                descriptionStrings.append("create")
//            }
//            if contains(.delete) {
//                descriptionStrings.append("delete")
//            }
//            if contains(.webHooks) {
//                descriptionStrings.append("web_hooks")
//            }
//            return descriptionStrings
//        }
//    }
}
