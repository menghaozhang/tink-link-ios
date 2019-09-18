import Foundation
import SwiftGRPC

final class UserService {
    let channel: Channel
    let metadata: Metadata

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    private lazy var service = UserServiceServiceClient(channel: channel, metadata: metadata)

    func createAnonymous(market: Market? = nil, locale: Locale, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market?.code ?? ""
        // TODO: Use the correct/acceptable locale PFMF-1298
        request.locale = locale.identifier
        request.origin = origin ?? ""

        return startCall(for: request, method: service.createAnonymous, responseMap: { AccessToken($0.accessToken) }, completion: completion)
    }
}
