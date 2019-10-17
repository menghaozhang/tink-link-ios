import Foundation
import SwiftGRPC

extension Metadata {
    enum HeaderKey: String {
        case clientKey = "X-Tink-Client-Key"
        case deviceID = "X-Tink-Device-ID"
        case authorization = "Authorization"
        case oauthClientID = "X-Tink-OAuth-Client-ID"

        var key: String {
            return rawValue.lowercased()
        }
    }

    func addAccessToken(_ token: String? = nil) throws {
        if let accessToken = token {
            try add(key: HeaderKey.authorization.key, value: "Bearer \(accessToken)")
        }
    }

    var hasAuthorization: Bool {
        self[Metadata.HeaderKey.authorization.key] != nil
    }
}
