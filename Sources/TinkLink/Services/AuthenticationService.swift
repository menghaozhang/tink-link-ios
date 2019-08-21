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

        let canceller = CallCanceller()

        do {
            canceller.call = try service.login(request) { (response, result) in
                if let response = response {
                    completion(.success(response.sessionID))
                } else {
                    let error = RPCError.callError(result)
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }

        return canceller
    }

    public func register(authenticationToken: String, email: String, locale: Locale, completion: @escaping (Result<String, Error>) -> Void) -> Cancellable {
        var request = GRPCRegisterRequest()
        request.authenticationToken = authenticationToken
        request.email = email
        request.locale = locale.identifier

        let canceller = CallCanceller()

        do {
            canceller.call = try service.register(request) { (response, result) in
                if let response = response {
                    completion(.success(response.sessionID))
                } else {
                    let error = RPCError.callError(result)
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }

        return canceller
    }

    public func logout(autologout: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCLogoutRequest()
        request.autologout = autologout

        let canceller = CallCanceller()

        do {
            canceller.call = try service.logout(request) { (response, result) in
                if response != nil {
                    completion(.success(()))
                } else {
                    let error = RPCError.callError(result)
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }

        return canceller
    }
}
