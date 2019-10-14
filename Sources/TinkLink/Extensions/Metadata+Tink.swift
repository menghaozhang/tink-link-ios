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
        let info = ProcessInfo.processInfo
        if let bearerToken = info.tinkBearerToken {
            try add(key: HeaderKey.authorization.key, value: "Bearer \(bearerToken)")
        } else if let accessToken = token {
            try add(key: HeaderKey.authorization.key, value: "Bearer \(accessToken)")
        }
    }

    var hasAuthorization: Bool {
        self[Metadata.HeaderKey.authorization.key] != nil
    }

    func addTinkMetadata() throws {
        let info = ProcessInfo.processInfo
        if let deviceID = info.tinkDeviceID {
            try add(key: HeaderKey.deviceID.key, value: deviceID)
        }
        if let sessionID = info.tinkSessionID {
            try add(key: HeaderKey.authorization.key, value: "Session \(sessionID)")
        }
    }
}
