import Foundation
import SwiftGRPC

public final class UserService {
    let channel: Channel
    let metadata: Metadata

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    private lazy var service = UserServiceServiceClient(channel: channel, metadata: metadata)

    public func createAnonymous(market: Market? = nil, locale: Locale = .current, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market?.code ?? ""
        // TODO: Use the correct/acceptable locale PFMF-1298
        request.locale = "sv_SE"
        request.origin = origin ?? ""

        return startCall(for: request, method: service.createAnonymous, responseMap: { AccessToken($0.accessToken) }, completion: completion)
    }
}
