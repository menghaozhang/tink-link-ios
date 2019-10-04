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

    func describeOAuth2Client(clientID: String, scopes: [String], redirectURL: URL, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDescribeOAuth2ClientRequest()
        request.clientID = clientID
        request.scopes = scopes
        request.redirectUri = redirectURL.absoluteString

        return CallHandler(for: request, method: service.describeOAuth2Client, responseMap: { _ in return }, completion: completion)
    }
}
