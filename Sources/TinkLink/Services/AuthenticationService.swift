import Foundation
import SwiftGRPC

final class AuthenticationService: TokenConfigurableService {
    let channel: Channel
    let metadata: Metadata
    let restURL: URL

    private var session: URLSession
    private var sessionDelegate: URLSessionDelegate?

    init(channel: Channel, metadata: Metadata, restURL: URL, certificates: [Data]) {
        self.channel = channel
        self.metadata = metadata
        self.restURL = restURL
        if certificates.isEmpty {
            session = .shared
        } else {
            sessionDelegate = CertificatePinningDelegate(certificates: certificates)
            session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
        }
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

extension AuthenticationService {
    func authorize(redirectURI: URL, scope: String, completion: @escaping (Result<AuthorizationResponse, Error>) -> Void) -> Cancellable? {
        guard let clientID = metadata[Metadata.HeaderKey.oauthClientID.key] else {
            preconditionFailure("No client id")
        }
        guard let authorization = metadata[Metadata.HeaderKey.authorization.key] else {
            preconditionFailure("Not authorized")
        }

        guard var urlComponents = URLComponents(url: restURL, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid restURL")
        }
        urlComponents.path = "/api/v1/oauth/authorize"

        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        do {
            let body = [
                "clientId": clientID,
                "redirectUri": redirectURI.absoluteString,
                "scope": scope,
            ]
            urlRequest.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return nil
        }

        let task = session.dataTask(with: urlRequest) { (data, _, error) in
            if let data = data {
                do {
                    let authorizationResponse = try JSONDecoder().decode(AuthorizationResponse.self, from: data)
                    completion(.success(authorizationResponse))
                } catch {
                    let authorizationError = try? JSONDecoder().decode(AuthorizationError.self, from: data)
                    completion(.failure(authorizationError ?? error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(URLError(.unknown)))
            }
        }

        task.resume()

        return task
    }
}
