import Foundation
import SwiftGRPC

final class Client {
    var channel: Channel
    var metadata = Metadata()
    var restURL: URL
    var grpcURL: URL
    var restCertificate: Data?
    var grpcCertificate: Data?
    var arguments: [Channel.Argument]
    
    var clientNetworkMonitor: ClientNetworkMonitor?

    private let clientKey = "e0e2c59be49f40a2ac3f21ae6893cbe7"

    init(environment: Environment, clientID: String, userAgent: String? = nil, grpcCertificate: Data? = nil, restCertificate: Data? = nil) {
        self.arguments = []
        self.restURL = environment.restURL
        self.grpcURL = environment.grpcURL
        self.restCertificate = restCertificate
        self.grpcCertificate = grpcCertificate

        arguments.append(.maxReceiveMessageLength(20 * 1024 * 1024))

        if let userAgent = userAgent {
            arguments.append(.primaryUserAgent(userAgent))
        }

        if let certificateContents = grpcCertificate?.base64EncodedString() {
            self.channel = Channel(address: grpcURL.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientKey, arguments: arguments)
        } else {
            self.channel = Channel(address: grpcURL.absoluteString, secure: true, arguments: arguments)
        }

        do {
            try metadata.add(key: Metadata.HeaderKey.oauthClientID.key, value: clientID)
            try metadata.add(key: Metadata.HeaderKey.clientKey.key, value: clientKey)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        
        self.clientNetworkMonitor = ClientNetworkMonitor(callback: { [weak self] state in
            if state.isReachable {
                self?.setupChannel()
            } else {
                self?.shutdownChannel()
            }
        })
    }
    
    func shutdownChannel() {
        channel.shutdown()
    }
    
    func setupChannel() {
        if let certificateContents = grpcCertificate?.base64EncodedString() {
            self.channel = Channel(address: grpcURL.absoluteString, certificates: certificateContents, clientCertificates: nil, clientKey: clientKey, arguments: arguments)
        } else {
            self.channel = Channel(address: grpcURL.absoluteString, secure: true, arguments: arguments)
        }
    }
}

extension Client {
    convenience init(configuration: TinkLink.Configuration) {
        self.init(
            environment: configuration.environment,
            clientID: configuration.clientID,
            grpcCertificate: configuration.grpcCertificate,
            restCertificate: configuration.restCertificate
        )
    }
}
