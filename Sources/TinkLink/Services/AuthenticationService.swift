import Foundation
import SwiftGRPC

public final class AuthenticationService: TokenConfigurableService {
    let channel: Channel
    let metadata: Metadata

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    internal lazy var service: AuthenticationServiceServiceClient = {
        let service = AuthenticationServiceServiceClient(channel: channel)
        service.metadata = metadata
        return service
    }()

    public func login(authenticationToken: AuthenticationToken, completion: @escaping (Result<String, Error>) -> Void) -> Cancellable {
        var request = GRPCLoginRequest()
        request.authenticationToken = authenticationToken.rawValue

        return startCall(for: request, method: service.login, responseMap: { $0.sessionID }, completion: completion)
    }

    public func register(authenticationToken: AuthenticationToken, email: String, locale: Locale, completion: @escaping (Result<String, Error>) -> Void) -> Cancellable {
        var request = GRPCRegisterRequest()
        request.authenticationToken = authenticationToken.rawValue
        request.email = email
        request.locale = locale.identifier

        return startCall(for: request, method: service.register, responseMap: { $0.sessionID }, completion: completion)
    }

    public func logout(autologout: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCLogoutRequest()
        request.autologout = autologout

        return startCall(for: request, method: service.logout, responseMap: { _ in return }, completion: completion)
    }

    public func describeOAuth2Client(clientID: String, scopes: [String], redirectURL: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCDescribeOAuth2ClientRequest()
        request.clientID = clientID
        request.scopes = scopes
        request.redirectUri = redirectURL.absoluteString

        return startCall(for: request, method: service.describeOAuth2Client, responseMap: { _ in return }, completion: completion)
    }
}
