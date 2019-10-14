import Foundation

extension TinkLink {
    /// Configuration used to set up the TinkLink
    public struct Configuration {
        public var clientID: String
        public var environment: Environment
        public var grpcCertificate: Data?
        public var restCertificate: Data?
        public var market: Market
        public var locale: Locale
        public var redirectURI: URL

        /// - Parameters:
        ///   - clientId: The client id for your app.
        ///   - environment: The environment to use, defaults to production.
        ///   - grpcCertificateURL: URL to a certificate file to use with gRPC API.
        ///   - restCertificateURL: URL to a certificate file to use with REST API.
        ///   - market: Optional, default market(SE) will be used if nothing is provided.
        ///   - locale: Optional, default locale(sv_SE) will be used if nothing is provided.
        ///   - redirectURI: The URI you've setup in Console.
        public init(
            clientID: String,
            environment: Environment = .production,
            grpcCertificateURL: URL? = nil,
            restCertificateURL: URL? = nil,
            market: Market? = nil,
            locale: Locale? = nil,
            redirectURI: URL
        ) {
            self.clientID = clientID
            self.environment = .production
            self.grpcCertificate = grpcCertificateURL.flatMap { try? Data(contentsOf: $0) }
            self.restCertificate = restCertificateURL.flatMap { try? Data(contentsOf: $0) }
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
            self.redirectURI = redirectURI
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
        case grpcCertificate = "TINK_GRPC_CERTIFICATE"
        case restCertificate = "TINK_REST_CERTIFICATE"
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
            self.grpcCertificate = try? Data(contentsOf: certificateURL)
        } else if let certificateData = try values.decodeIfPresent(Data.self, forKey: .grpcCertificate) {
            self.grpcCertificate = certificateData
        }
        if let certificateFileName = try values.decodeIfPresent(String.self, forKey: .restCertificateFileName) {
            guard let certificateURL = Bundle.main.url(forResource: certificateFileName, withExtension: "cer") else {
                fatalError("Cannot find REST certificate file")
            }
            self.restCertificate = try? Data(contentsOf: certificateURL)
        } else if let certificateData = try values.decodeIfPresent(Data.self, forKey: .restCertificate) {
            self.restCertificate = certificateData
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

        redirectURI = try values.decode(URL.self, forKey: .redirectURI)
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
        if let data = grpcCertificate {
            try container.encode(data, forKey: .grpcCertificate)
        }
        if let data = restCertificate {
            try container.encode(data, forKey: .restCertificate)
        }
        try container.encode(market.rawValue, forKey: .market)
        try container.encode(locale.identifier, forKey: .locale)
        try container.encode(redirectURI, forKey: .redirectURI)
    }
}

extension TinkLink.Configuration {
    enum Error: Swift.Error, LocalizedError {
        case clientIDNotFound
        case redirectURINotFound

        var errorDescription: String? {
            switch self {
            case .clientIDNotFound:
                return "`TINK_CLIENT_ID` was not found in environment variable or Info.plist. Please configure a Tink Link client before using it."
            case .redirectURINotFound:
                return "`TINK_REDIRECT_URI` was not found in environment variable or Info.plist. Please configure a Tink Link client before using it."
            }
        }
    }

    init(plistURL: URL) throws {
        let data = try Data(contentsOf: plistURL)
        self = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
    }

    init(processInfo: ProcessInfo) throws {
        guard let clientID = processInfo.tinkClientID else { throw Error.clientIDNotFound }
        guard let redirectURI = processInfo.tinkRedirectURI else { throw Error.redirectURINotFound }
        self.environment = processInfo.tinkEnvironment ?? .production
        self.clientID = clientID
        self.grpcCertificate = processInfo.tinkGrpcCertificate.flatMap { Data(base64Encoded: $0) }
        self.restCertificate = processInfo.tinkRestCertificate.flatMap { Data(base64Encoded: $0) }
        self.market = processInfo.tinkMarket ?? TinkLink.defaultMarket
        self.locale = processInfo.tinkLocale ?? TinkLink.defaultLocale
        self.redirectURI = redirectURI
    }
}
