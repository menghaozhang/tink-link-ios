import Foundation
import SwiftGRPC

final class AuthenticationService: TokenConfigurableService {
    let channel: Channel
    let metadata: Metadata
    let restURL: URL

    private var session: URLSession
    private var sessionDelegate: URLSessionDelegate?

    /// Creates a `AuthenticationService` to get the `AuthorizationCode` from Tink API.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    /// - Parameter accessToken: The access token that can be used to communicate with the TInk API
    convenience init(tinkLink: TinkLink = .shared, accessToken: AccessToken) {
        do {
            try tinkLink.client.metadata.addAccessToken(accessToken.rawValue)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        self.init(channel: tinkLink.client.channel, metadata: tinkLink.client.metadata, restURL: tinkLink.client.restURL, certificates: tinkLink.client.restCertificate.map { [$0] } ?? [])
    }

    init(channel: Channel, metadata: Metadata, restURL: URL, certificates: [Data]) {
        self.channel = channel
        self.metadata = metadata
        self.restURL = restURL
        if certificates.isEmpty {
            self.session = .shared
        } else {
            self.sessionDelegate = CertificatePinningDelegate(certificates: certificates)
            self.session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
        }
    }

    internal lazy var service = AuthenticationServiceServiceClient(channel: channel, metadata: metadata)

    func describeOAuth2Client(clientID: String, scopes: [String], redirectURI: URL, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDescribeOAuth2ClientRequest()
        request.clientID = clientID
        request.scopes = scopes
        request.redirectUri = redirectURI.absoluteString

        return CallHandler(for: request, method: service.describeOAuth2Client, responseMap: { _ in }, completion: completion)
    }
}

extension AuthenticationService {
    func authorize(redirectURI: URL, scope: TinkLink.Scope, completion: @escaping (Result<AuthorizationResponse, Error>) -> Void) -> Cancellable? {
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
                "scope": scope.description,
            ]
            urlRequest.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return nil
        }

        let task = session.dataTask(with: urlRequest) { data, _, error in
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
