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
        guard let grpcEndpoint = environment["TINK_CUSTOM_GRPC_ENDPOINT"].flatMap(URL.init(string: )),
            let restEndpoint = environment["TINK_CUSTOM_REST_ENDPOINT"].flatMap(URL.init(string: ))
            else { return nil }
        return Environment.custom(grpcURL: grpcEndpoint, restURL: restEndpoint)
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

    var tinkAuthorizeHost: String? {
        return environment["TINK_AUTHORIZE_HOST"]
    }
}
