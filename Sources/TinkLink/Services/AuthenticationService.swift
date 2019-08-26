import Foundation
import SwiftGRPC

public final class AuthenticationService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service: AuthenticationServiceServiceClient = {
        let service = AuthenticationServiceServiceClient(channel: channel)
        do {
            try service.metadata.addTinkMetadata()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return service
    }()

    public func login(authenticationToken: String, completion: @escaping (Result<String, Error>) -> Void) -> Cancellable {
        var request = GRPCLoginRequest()
        request.authenticationToken = authenticationToken

        return startCall(for: request, method: service.login, responseMap: { $0.sessionID }, completion: completion)
    }

    public func register(authenticationToken: String, email: String, locale: Locale, completion: @escaping (Result<String, Error>) -> Void) -> Cancellable {
        var request = GRPCRegisterRequest()
        request.authenticationToken = authenticationToken
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
