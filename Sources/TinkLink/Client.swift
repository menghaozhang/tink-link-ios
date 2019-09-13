import Foundation
import SwiftGRPC

final class Client {
    let channel: Channel
    private var cancellable: Cancellable?

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

        if let certificateContents = certificate {
            self.channel = Channel(address: environment.url.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientKey, arguments: arguments)
        } else {
            self.channel = Channel(address: environment.url.absoluteString, secure: true, arguments: arguments)
        }
    }
    
    func fetchAccessToken() {
        guard cancellable == nil else { return }
        cancellable = userService.createAnonymous { [weak self] result in
            guard let self = self else { return }
            if let accessToken = try? result.get() {
                self.accessToken = accessToken
            }
            self.cancellable = nil
        }
    }
    
    var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                tokenConfigurableServices.forEach { $0.configure(accessToken) }
            }
        }
    }
    
    private var tokenConfigurableServices: [TokenConfigurableServiceBase] = []

    private(set) lazy var providerService: ProviderService = {
        let service = ProviderService(channel: channel, accessToken: accessToken)
        tokenConfigurableServices.append(service)
        return service
    }()
    private(set) lazy var credentialService: CredentialService = {
        let service = CredentialService(channel: channel, accessToken: accessToken)
        tokenConfigurableServices.append(service)
        return service
    }()
    private(set) lazy var accountService: AccountService = {
        let service = AccountService(channel: channel, accessToken: accessToken)
        tokenConfigurableServices.append(service)
        return service
    }()
    private(set) lazy var authenticationService: AuthenticationService = {
        let service = AuthenticationService(channel: channel, accessToken: accessToken)
        tokenConfigurableServices.append(service)
        return service
    }()
    private(set) lazy var streamingService = StreamingService(channel: channel)
    private(set) lazy var userService = UserService(channel: channel)
}
