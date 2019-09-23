import Foundation
import SwiftGRPC

final class AuthenticationService: TokenConfigurableService {
    let channel: Channel
    let metadata: Metadata

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    internal lazy var service = AuthenticationServiceServiceClient(channel: channel, metadata: metadata)

    func login(authenticationToken: AuthenticationToken, completion: @escaping (Result<String, Error>) -> Void) -> RetryCancellable {
        var request = GRPCLoginRequest()
        request.authenticationToken = authenticationToken.rawValue

        return CallHandler(for: request, method: service.login, responseMap: { $0.sessionID }, completion: completion)
    }

    func register(authenticationToken: AuthenticationToken, email: String, locale: Locale, completion: @escaping (Result<String, Error>) -> Void) -> RetryCancellable {
        var request = GRPCRegisterRequest()
        request.authenticationToken = authenticationToken.rawValue
        request.email = email
        request.locale = locale.identifier

        return CallHandler(for: request, method: service.register, responseMap: { $0.sessionID }, completion: completion)
    }

    func logout(autologout: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCLogoutRequest()
        request.autologout = autologout

        return CallHandler(for: request, method: service.logout, responseMap: { _ in return }, completion: completion)
    }

    func describeOAuth2Client(clientID: String, scopes: [String], redirectURL: URL, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDescribeOAuth2ClientRequest()
        request.clientID = clientID
        request.scopes = scopes
        request.redirectUri = redirectURL.absoluteString

        return CallHandler(for: request, method: service.describeOAuth2Client, responseMap: { _ in return }, completion: completion)
    }
}
