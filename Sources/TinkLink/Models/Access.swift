import Foundation
/// Access to user data is controlled by using OAuth2 security scopes or permissions. Each API customer is configured to have a set of scopes which control the maximum permitted data access.
extension TinkLink {
    public struct Access: OptionSet, Hashable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let read = TinkLink.Access(rawValue: 1 << 0)
        public static let write = TinkLink.Access(rawValue: 1 << 1)
        public static let grant = TinkLink.Access(rawValue: 1 << 2)
        public static let revoke = TinkLink.Access(rawValue: 1 << 3)
        public static let refresh = TinkLink.Access(rawValue: 1 << 4)
        public static let categorize = TinkLink.Access(rawValue: 1 << 5)
        public static let execute = TinkLink.Access(rawValue: 1 << 6)
        public static let create = TinkLink.Access(rawValue: 1 << 7)
        public static let delete = TinkLink.Access(rawValue: 1 << 8)
        public static let webHooks = TinkLink.Access(rawValue: 1 << 9)

        var descriptions: [String] {
            var descriptionStrings = [String]()
            if contains(.read) {
                descriptionStrings.append("read")
            }
            if contains(.write) {
                descriptionStrings.append("write")
            }
            if contains(.grant) {
                descriptionStrings.append("grant")
            }
            if contains(.revoke) {
                descriptionStrings.append("revoke")
            }
            if contains(.refresh) {
                descriptionStrings.append("refresh")
            }
            if contains(.categorize) {
                descriptionStrings.append("categorize")
            }
            if contains(.execute) {
                descriptionStrings.append("execute")
            }
            if contains(.create) {
                descriptionStrings.append("create")
            }
            if contains(.delete) {
                descriptionStrings.append("delete")
            }
            if contains(.webHooks) {
                descriptionStrings.append("web_hooks")
            }
            return descriptionStrings
        }
    }
}
