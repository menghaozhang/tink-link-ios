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

    var tinkEnvironment: Environment? {
        return environment["TINK_ENVIRONMENT"].flatMap(Environment.init(rawValue:))
    }
}

extension Metadata {
    private enum HeaderKeys: String {
        case clientKey = "x-tink-client-key"
        case deviceId = "x-tink-device-id"
        case authorization = "authorization"
        case clientId = "x-tink-oauth-client-id"
    }
    
    func addAccessToken(_ token: String? = nil) throws {
        let info = ProcessInfo.processInfo
        if let bearerToken = info.tinkBearerToken {
            try add(key: HeaderKeys.authorization.rawValue, value: "Bearer \(bearerToken)")
        } else if let accessToken = token {
            try add(key: HeaderKeys.authorization.rawValue, value: "Bearer \(accessToken)")
        }
    }
    
    func addTinkMetadata() throws {
        let info = ProcessInfo.processInfo
        if let clientKey = info.tinkClientKey {
            try add(key: HeaderKeys.clientKey.rawValue, value: clientKey)
        }
        if let deviceID = info.tinkDeviceID {
            try add(key: HeaderKeys.deviceId.rawValue, value: deviceID)
        }
        if let sessionID = info.tinkSessionID {
            try add(key: HeaderKeys.authorization.rawValue, value: "Session \(sessionID)")
        }
        if let oAuthClientID = info.tinkOAuthClientID {
            try add(key: HeaderKeys.clientId.rawValue, value: oAuthClientID)
        }
        let authorization = dictionaryRepresentation[HeaderKeys.authorization.rawValue]
        try addAccessToken(authorization)
    }
}
