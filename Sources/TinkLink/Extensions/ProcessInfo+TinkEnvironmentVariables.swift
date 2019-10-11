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

    var tinkGrpcCertificate: String? {
        return environment["TINK_GRPC_CERTIFICATE"]
    }

    var tinkRestCertificate: String? {
        return environment["TINK_REST_CERTIFICATE"]
    }

    var tinkEnvironment: Environment? {
        guard let grpcEndpoint = environment["TINK_CUSTOM_GRPC_ENDPOINT"].flatMap(URL.init(string: )),
            let restEndpoint = environment["TINK_CUSTOM_REST_ENDPOINT"].flatMap(URL.init(string: ))
            else { return nil }
        return Environment.custom(grpcURL: grpcEndpoint, restURL: restEndpoint)
    }

    var tinkMarket: Market? {
        return environment["TINK_MARKET_CODE"].flatMap(Market.init(code:))
    }

    var tinkLocale: Locale? {
        if let locale = environment["TINK_LOCALE_IDENTIFIER"].flatMap(Locale.init(identifier:)) {
            if TinkLink.availableLocales.contains(locale) {
                return locale
            }
        }
        return nil
    }

    var tinkRedirectURI: URL? {
        return environment["TINK_REDIRECT_URI"].flatMap(URL.init(string:))
    }
}
