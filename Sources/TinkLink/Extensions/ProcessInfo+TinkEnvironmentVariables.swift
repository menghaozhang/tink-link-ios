import Foundation

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
        return environment["TINK_MARKET_CODE"].flatMap(Market.init(code: ))
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
