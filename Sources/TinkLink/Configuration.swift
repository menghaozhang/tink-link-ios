import Foundation

extension TinkLink {
    /// Configuration used to set up the TinkLink
    public struct Configuration {
        var clientID: String
        var environment: Environment
        // keep this internal in case need to set up the URL
        var certificateURL: URL?
        var market: Market
        var locale: Locale
        /// - Parameters:
        ///   - clientId: The client id for your app.
        ///   - market: Optional, default market(SE) will be used if nothing is provided.
        ///   - locale: Optional, default locale(sv_SE) will be used if nothing is provided.
        public init(clientID: String, market: Market? = nil, locale: Locale? = nil) {
            self.environment = .production
            self.clientID = clientID
            self.market = market ?? .defaultMarket
            if let locale = locale {
                if TinkLink.availableLocales.contains(locale) {
                    self.locale = locale
                } else {
                    fatalError(locale.identifier + " is not an available locale")
                }
            } else {
                self.locale = TinkLink.defaultLocale
            }
        }
    }
}

extension TinkLink.Configuration: Decodable {
    enum CodingKeys: String, CodingKey {
        case environmentEndpoint = "TINK_CUSTOM_END_POINT"
        case clientID = "TINK_CLIENT_ID"
        case certificateFileName = "TINK_CERTIFICATE_FILE_NAME"
        case market = "TINK_MARKET_CODE"
        case locale = "TINK_LOCALE_IDENTIFIER"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        clientID = try values.decode(String.self, forKey: .clientID)
        if let environmentEndpoint = try? values.decode(String.self, forKey: .environmentEndpoint), let url = URL(string: environmentEndpoint) {
            self.environment = .custom(url)
        } else {
            self.environment = .production
        }
        if let certificateFileName = try values.decodeIfPresent(String.self, forKey: .certificateFileName) {
            guard let certificateURL = Bundle.main.url(forResource: certificateFileName, withExtension: "pem") else {
                fatalError("Cannot find certificate file")
            }
            self.certificateURL = certificateURL
        }

        if let marketCode = try values.decodeIfPresent(String.self, forKey: .market) {
            market = Market(code: marketCode)
        } else {
            market = TinkLink.defaultMarket
        }

        if let localeIdentifier = try values.decodeIfPresent(String.self, forKey: .locale) {
            let availableLocale = TinkLink.availableLocales.first{ $0.identifier == localeIdentifier }
            if let locale = availableLocale {
                self.locale = locale
            } else {
                fatalError(localeIdentifier + " is not an available locale")
            }
        } else {
            locale = TinkLink.defaultLocale
        }
    }
}

extension TinkLink.Configuration {
    enum Error: Swift.Error, LocalizedError {
        case clientIDNotFound

        var errorDescription: String? {
            return "`TINK_CLIENT_ID` was not found in environment variable or Info.plist."
        }
    }

    init(plistURL: URL) throws {
        let data = try Data(contentsOf: plistURL)
        self = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
    }

    init(processInfo: ProcessInfo) throws {
        guard let clientID = processInfo.tinkClientID else { throw Error.clientIDNotFound }
        self.environment = processInfo.tinkEnvironment ?? .production
        self.clientID = clientID
        // FIXME: self.certificate = processInfo.tinkCertificate
        self.certificateURL = nil
        self.market = processInfo.tinkMarket ?? TinkLink.defaultMarket
        self.locale = processInfo.tinkLocale ?? TinkLink.defaultLocale
    }
}
