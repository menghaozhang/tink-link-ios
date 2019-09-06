import Foundation
import SwiftGRPC

extension ProcessInfo {
    var tinkClientKey: String? {
        return environment["TINK_CLIENT_KEY"]
    }

    var tinkDeviceID: String? {
        return environment["TINK_DEVICE_ID"]
    }

    var tinkSessionID: String? {
        return environment["TINK_SESSION_ID"]
    }

    var tinkOAuthClientID: String? {
        return environment["TINK_OAUTH_CLIENT_ID"]
    }

    var tinkBearerToken: String? {
        return environment["TINK_BEARER_TOKEN"]
    }

    var tinkCertificate: String? {
        return environment["TINK_CERTIFICATE"]
    }
}

extension Metadata {
    func addTinkMetadata() throws {
        let info = ProcessInfo.processInfo
        if let clientKey = info.tinkClientKey {
            try add(key: "X-Tink-Client-Key".lowercased(), value: clientKey)
        }
        if let deviceID = info.tinkDeviceID {
            try add(key: "X-Tink-Device-Id".lowercased(), value: deviceID)
        }
        if let sessionID = info.tinkSessionID {
            try add(key: "Authorization".lowercased(), value: "Session \(sessionID)")
        }
        if let oAuthClientID = info.tinkOAuthClientID {
            try add(key: "X-Tink-OAuth-Client-ID".lowercased(), value: oAuthClientID)
        }
        if let bearerToken = info.tinkBearerToken {
            try add(key: "Authorization".lowercased(), value: "Bearer \(bearerToken)")
        }
    }
}
