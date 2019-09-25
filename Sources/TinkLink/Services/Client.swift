import Foundation
import SwiftGRPC

final class Client {
    let channel: Channel
    private var metadata = Metadata()
    var market: Market
    var locale: Locale

    convenience init(environment: Environment, clientID: String, userAgent: String? = nil, certificateURL: URL? = nil, market: Market, locale: Locale) {
        let certificateContents = certificateURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        self.init(environment: environment, clientID: clientID, userAgent: userAgent, certificate: certificateContents, market: market, locale: locale)
    }

    init(environment: Environment, clientID: String, userAgent: String? = nil, certificate: String? = nil, market: Market, locale: Locale) {
        var arguments: [Channel.Argument] = []
        self.market = market
        self.locale = locale

        arguments.append(.maxReceiveMessageLength(20 * 1024 * 1024))

        if let userAgent = userAgent {
            arguments.append(.primaryUserAgent(userAgent))
        }

        if let certificateContents = certificate {
            self.channel = Channel(address: environment.url.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientID, arguments: arguments)
        } else {
            self.channel = Channel(address: environment.url.absoluteString, secure: true, arguments: arguments)
        }

        do {
            try metadata.add(key: Metadata.HeaderKey.oauthClientID.key, value: clientID)
            try metadata.addTinkMetadata()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private(set) lazy var providerService = ProviderService(channel: channel, metadata: metadata)
    private(set) lazy var credentialService = CredentialService(channel: channel, metadata: metadata)
    private(set) lazy var authenticationService = AuthenticationService(channel: channel, metadata: metadata)
    private(set) lazy var streamingService = StreamingService(channel: channel, metadata: metadata)
    private(set) lazy var userService = UserService(channel: channel, metadata: metadata)
}

extension Client {
    convenience init(configurationUrl: URL) throws {
        let data = try Data(contentsOf: configurationUrl)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        self.init(environment: configuration.environment, clientID: configuration.clientId, certificateURL: configuration.certificateURL, market: configuration.market, locale: configuration.locale)
    }

    convenience init?(processInfo: ProcessInfo) {
        guard let clientID = processInfo.tinkClientID else { return nil }
        self.init(
            environment: processInfo.tinkEnvironment ?? .staging,
            clientID: clientID,
            certificate: processInfo.tinkCertificate,
            market: processInfo.tinkMarket ?? TinkLink.defaultMarket,
            locale: processInfo.tinkLocale ?? TinkLink.defaultLocale
        )
    }
}
