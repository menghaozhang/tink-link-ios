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
    private enum HeaderKeys: CustomStringConvertible {
        case clientKey
        case deviceId
        case authorization
        case clientId
        
        public var description: String {
            switch self {
            case .clientKey:
                return "X-Tink-Client-Key".lowercased()
            case .deviceId:
                return  "X-Tink-Device-Id".lowercased()
            case .authorization:
                return "Authorization".lowercased()
            case .clientId:
                return "X-Tink-OAuth-Client-ID".lowercased()
            }
        }
    }
    
    func addAccessToken(_ token: String? = nil) throws {
        let info = ProcessInfo.processInfo
        if let bearerToken = info.tinkBearerToken {
            try add(key: "Authorization".lowercased(), value: "Bearer \(bearerToken)")
        } else if let accessToken = token {
            try add(key: "Authorization".lowercased(), value: "Bearer \(accessToken)")
        }
    }
    
    func addTinkMetadata() throws {
        let info = ProcessInfo.processInfo
        if let clientKey = info.tinkClientKey {
            try add(key: HeaderKeys.clientKey.description, value: clientKey)
        }
        if let deviceID = info.tinkDeviceID {
            try add(key: HeaderKeys.deviceId.description, value: deviceID)
        }
        if let sessionID = info.tinkSessionID {
            try add(key: HeaderKeys.authorization.description, value: "Session \(sessionID)")
        }
        if let oAuthClientID = info.tinkOAuthClientID {
            try add(key: HeaderKeys.clientId.description, value: oAuthClientID)
        }
        let authorization = dictionaryRepresentation[HeaderKeys.authorization.description]
        try addAccessToken(authorization)
    }
}
