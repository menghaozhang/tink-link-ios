import Foundation
import SwiftGRPC

extension ProcessInfo {
    var tinkClientID: String? {
        return environment["TINK_CLIENT_ID"]
    }

    var tinkDeviceID: String? {
        return environment["TINK_DEVICE_ID"]
    }

    var tinkSessionID: String? {
        return environment["TINK_SESSION_ID"]
    }

    var tinkBearerToken: String? {
        return environment["TINK_BEARER_TOKEN"]
    }

    var tinkCertificate: String? {
        return environment["TINK_CERTIFICATE"]
    }

    var tinkEnvironment: Environment? {
        return environment["TINK_CUSTOM_ENDPOINT"].flatMap(URL.init(string: )).flatMap { Environment.custom($0) }
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
