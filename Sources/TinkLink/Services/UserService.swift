import Foundation
import SwiftGRPC

final class UserService {
    let channel: Channel
    let metadata: Metadata

    /// Creates a `UserService` to get `AccessToken` from Tink API.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    convenience init(tinkLink: TinkLink = .shared) {
        self.init(channel: tinkLink.client.channel, metadata: tinkLink.client.metadata)
    }

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    private lazy var service = UserServiceServiceClient(channel: channel, metadata: metadata)

    func createAnonymous(market: Market? = nil, locale: Locale, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market?.code ?? ""
        request.locale = locale.identifier
        request.origin = origin ?? ""

        return CallHandler(for: request, method: service.createAnonymous, responseMap: { AccessToken($0.accessToken) }, completion: completion)
    }
}
