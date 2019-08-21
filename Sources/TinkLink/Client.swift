import Foundation
import SwiftGRPC

public final class Client {
    let channel: Channel

    public init(environment: Environment, clientKey: String, userAgent: String? = nil, certificateURL: URL? = nil) {
        var arguments: [Channel.Argument] = []

        arguments.append(.maxReceiveMessageLength(20 * 1024 * 1024))

        if let userAgent = userAgent {
            arguments.append(.primaryUserAgent(userAgent))
        }

        if let certificateURL = certificateURL {
            let certificateContents = try! String(contentsOf: certificateURL, encoding: .utf8)
            self.channel = Channel(address: environment.url.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientKey, arguments: arguments)
        } else {
            self.channel = Channel(address: environment.url.absoluteString, secure: false, arguments: arguments)
        }
    }

    public private(set) lazy var providerService: ProviderService = ProviderService(channel: channel)
    public private(set) lazy var credentialService: CredentialService = CredentialService(channel: channel)
    public private(set) lazy var accountService = AccountService(channel: channel)
}
