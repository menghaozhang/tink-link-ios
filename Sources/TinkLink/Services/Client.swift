import Foundation
import SwiftGRPC

final class Client {
    let channel: Channel
    private var metadata = Metadata()
    var market: Market
    var locale: Locale
    var restURL: URL
    var restCertificate: Data?

    convenience init(environment: Environment, clientID: String, userAgent: String? = nil, grpcCertificateURL: URL? = nil, restCertificateURL: URL? = nil, market: Market, locale: Locale) {
        let grpcCertificateContents = grpcCertificateURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        let restCertificateContents = restCertificateURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        self.init(environment: environment, clientID: clientID, userAgent: userAgent, grpcCertificate: grpcCertificateContents, restCertificate: restCertificateContents, market: market, locale: locale)
    }

    init(environment: Environment, clientID: String, userAgent: String? = nil, grpcCertificate: String? = nil, restCertificate: String? = nil, market: Market, locale: Locale) {
        var arguments: [Channel.Argument] = []
        self.market = market
        self.locale = locale
        self.restURL = environment.restURL
        self.restCertificate = restCertificate?.data(using: .utf8)

        arguments.append(.maxReceiveMessageLength(20 * 1024 * 1024))

        if let userAgent = userAgent {
            arguments.append(.primaryUserAgent(userAgent))
        }

        if let certificateContents = grpcCertificate {
            self.channel = Channel(address: environment.grpcURL.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientID, arguments: arguments)
        } else {
            self.channel = Channel(address: environment.grpcURL.absoluteString, secure: true, arguments: arguments)
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
    private(set) lazy var authenticationService = AuthenticationService(channel: channel, metadata: metadata, restURL: restURL, certificates: restCertificate != nil ? [restCertificate!] : [])
    private(set) lazy var userService = UserService(channel: channel, metadata: metadata)
}

extension Client {
    convenience init(configuration: TinkLink.Configuration) {
        self.init(
            environment: configuration.environment,
            clientID: configuration.clientID,
            grpcCertificateURL: configuration.grpcCertificateURL,
            restCertificateURL: configuration.restCertificateURL,
            market: configuration.market,
            locale: configuration.locale
        )
    }
}
