import Foundation
import SwiftGRPC

final class Client {
    let channel: Channel
    var metadata = Metadata()
    var market: Market
    var locale: Locale
    var restURL: URL
    var restCertificate: Data?

    private let clientKey = "e0e2c59be49f40a2ac3f21ae6893cbe7"

    init(environment: Environment, clientID: String, userAgent: String? = nil, grpcCertificate: Data? = nil, restCertificate: Data? = nil, market: Market, locale: Locale) {
        var arguments: [Channel.Argument] = []
        self.market = market
        self.locale = locale
        self.restURL = environment.restURL
        self.restCertificate = restCertificate

        arguments.append(.maxReceiveMessageLength(20 * 1024 * 1024))

        if let userAgent = userAgent {
            arguments.append(.primaryUserAgent(userAgent))
        }

        if let certificateContents = grpcCertificate?.base64EncodedString() {
            self.channel = Channel(address: environment.grpcURL.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientKey, arguments: arguments)
        } else {
            self.channel = Channel(address: environment.grpcURL.absoluteString, secure: true, arguments: arguments)
        }

        do {
            try metadata.add(key: Metadata.HeaderKey.oauthClientID.key, value: clientID)
            try metadata.add(key: Metadata.HeaderKey.clientKey.key, value: clientKey)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

extension Client {
    convenience init(configuration: TinkLink.Configuration) {
        self.init(
            environment: configuration.environment,
            clientID: configuration.clientID,
            grpcCertificate: configuration.grpcCertificate,
            restCertificate: configuration.restCertificate,
            market: configuration.market,
            locale: configuration.locale
        )
    }
}
