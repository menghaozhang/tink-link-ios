import Foundation

extension TinkLink {
    /// Configuration used to set up the TinkLink
    public struct Configuration {
        var clientID: String
        var environment: Environment
        var grpcCertificateURL: URL?
        var restCertificateURL: URL?
        var market: Market
        var locale: Locale
        var redirectURI: URL?

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

extension TinkLink.Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case environmentGrpcEndpoint = "TINK_CUSTOM_GRPC_ENDPOINT"
        case environmentRestEndpoint = "TINK_CUSTOM_REST_ENDPOINT"
        case clientID = "TINK_CLIENT_ID"
        case grpcCertificateFileName = "TINK_GRPC_CERTIFICATE_FILE_NAME"
        case restCertificateFileName = "TINK_REST_CERTIFICATE_FILE_NAME"
        case market = "TINK_MARKET_CODE"
        case locale = "TINK_LOCALE_IDENTIFIER"
        case redirectURI = "TINK_REDIRECT_URI"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        clientID = try values.decode(String.self, forKey: .clientID)
        if let environmentGrpcEndpoint = try? values.decode(String.self, forKey: .environmentGrpcEndpoint),
            let grpcURL = URL(string: environmentGrpcEndpoint),
            let environmentRestEndpoint = try? values.decode(String.self, forKey: .environmentRestEndpoint),
            let restURL = URL(string: environmentRestEndpoint) {
            self.environment = .custom(grpcURL: grpcURL, restURL: restURL)
        } else {
            self.environment = .production
        }
        if let certificateFileName = try values.decodeIfPresent(String.self, forKey: .grpcCertificateFileName) {
            guard let certificateURL = Bundle.main.url(forResource: certificateFileName, withExtension: "pem") else {
                fatalError("Cannot find gRPC certificate file")
            }
            self.grpcCertificateURL = certificateURL
        }
        if let certificateFileName = try values.decodeIfPresent(String.self, forKey: .restCertificateFileName) {
            guard let certificateURL = Bundle.main.url(forResource: certificateFileName, withExtension: "cer") else {
                fatalError("Cannot find REST certificate file")
            }
            self.restCertificateURL = certificateURL
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

        redirectURI = try values.decodeIfPresent(URL.self, forKey: .redirectURI)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientID, forKey: .clientID)
        switch environment {
        case .production:
            break
        case .custom(let grpcUrl, let restUrl):
            try container.encode(grpcUrl.absoluteString, forKey: .environmentGrpcEndpoint)
            try container.encode(restUrl.absoluteString, forKey: .environmentRestEndpoint)
        }
        if let url = grpcCertificateURL {
            let fileName = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
            try container.encode(fileName, forKey: .grpcCertificateFileName)
        }
        if let url = restCertificateURL {
            let fileName = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
            try container.encode(fileName, forKey: .restCertificateFileName)
        }
        try container.encode(market.rawValue, forKey: .market)
        try container.encode(locale.identifier, forKey: .locale)
        try container.encodeIfPresent(redirectURI, forKey: .redirectURI)
    }
}

extension TinkLink.Configuration {
    enum Error: Swift.Error, LocalizedError {
        case clientIDNotFound

        var errorDescription: String? {
            return "`TINK_CLIENT_ID` was not found in environment variable or Info.plist. Please configure a Tink Link client before using it."
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
        self.grpcCertificateURL = nil // FIXME: processInfo.tinkGrpcCertificate
        self.restCertificateURL = nil // FIXME: processInfo.tinkRestCertificate
        self.market = processInfo.tinkMarket ?? TinkLink.defaultMarket
        self.locale = processInfo.tinkLocale ?? TinkLink.defaultLocale
        self.redirectURI = processInfo.tinkRedirectURI
    }
}
