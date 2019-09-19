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
    
    var tinkMarket: Market? {
        return environment["TINK_MARKET"].flatMap(Market.init(code: ))
    }
    
    var tinkLocale: Locale? {
        if let locale = environment["TINK_LOCALE"].flatMap(Locale.init(identifier: )) {
            if TinkLink.availableLocales.contains(locale) {
                return locale
            }
        }
        return nil
    }
}

extension Metadata {
    enum HeaderKeys: String {
        case clientKey = "X-Tink-Client-Key"
        case deviceId = "X-Tink-Device-ID"
        case authorization = "Authorization"
        case clientId = "X-Tink-OAuth-Client-ID"

        var key: String {
            return rawValue.lowercased()
        }
    }
    
    func addAccessToken(_ token: String? = nil) throws {
        let info = ProcessInfo.processInfo
        if let bearerToken = info.tinkBearerToken {
            try add(key: HeaderKeys.authorization.key, value: "Bearer \(bearerToken)")
        } else if let accessToken = token {
            try add(key: HeaderKeys.authorization.key, value: "Bearer \(accessToken)")
        }
    }
    
    func addTinkMetadata() throws {
        let info = ProcessInfo.processInfo
        if let deviceID = info.tinkDeviceID {
            try add(key: HeaderKeys.deviceId.key, value: deviceID)
        }
        if let sessionID = info.tinkSessionID {
            try add(key: HeaderKeys.authorization.key, value: "Session \(sessionID)")
        }
    }
}
