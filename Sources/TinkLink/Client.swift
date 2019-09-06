import Foundation
import SwiftGRPC

final class Client {
    let channel: Channel

    convenience init(environment: Environment, clientKey: String, userAgent: String? = nil, certificateURL: URL? = nil) {
        let certificateContents = certificateURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        self.init(environment: environment, clientKey: clientKey, userAgent: userAgent, certificate: certificateContents)
    }

    init(environment: Environment, clientKey: String, userAgent: String? = nil, certificate: String? = nil) {
        var arguments: [Channel.Argument] = []

        arguments.append(.maxReceiveMessageLength(20 * 1024 * 1024))

        if let userAgent = userAgent {
            arguments.append(.primaryUserAgent(userAgent))
        }

        if let certificateContents = certificate ?? ProcessInfo.processInfo.tinkCertificate {
            self.channel = Channel(address: environment.url.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientKey, arguments: arguments)
        } else {
            self.channel = Channel(address: environment.url.absoluteString, secure: false, arguments: arguments)
        }
    }

    public private(set) lazy var providerService = ProviderService(channel: channel)
    public private(set) lazy var credentialService = CredentialService(channel: channel)
    public private(set) lazy var accountService = AccountService(channel: channel)
    private(set) lazy var streamingService = StreamingService(channel: channel)
    public private(set) lazy var userService = UserService(channel: channel)
    public private(set) lazy var authenticationService = AuthenticationService(channel: channel)
}
