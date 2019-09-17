import Foundation
import SwiftGRPC

public final class UserService {
    let channel: Channel
    let clientKey: String

    init(channel: Channel, clientKey: String) {
        self.channel = channel
        self.clientKey = clientKey
    }

    private lazy var service: UserServiceServiceClient = {
        let service = UserServiceServiceClient(channel: channel)
        do {
            try service.metadata.add(key: Metadata.HeaderKeys.clientId.key, value: clientKey)
            try service.metadata.addTinkMetadata()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return service
    }()

    public func createAnonymous(market: Market? = nil, locale: Locale = .current, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market?.code ?? ""
        // TODO: Use the correct/acceptable locale PFMF-1298
        request.locale = "sv_SE"
        request.origin = origin ?? ""

        return startCall(for: request, method: service.createAnonymous, responseMap: { AccessToken($0.accessToken) }, completion: completion)
    }
}
