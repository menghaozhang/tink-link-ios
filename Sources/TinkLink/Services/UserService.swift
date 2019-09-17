import Foundation
import SwiftGRPC

public final class UserService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service: UserServiceServiceClient = {
        let service = UserServiceServiceClient(channel: channel)
        do {
            try service.metadata.addTinkMetadata()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return service
    }()

    public func createAnonymous(market: Market? = nil, locale: Locale, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market?.code ?? ""
        // TODO: Use the correct/acceptable locale PFMF-1298
        request.locale = locale.identifier
        request.origin = origin ?? ""

        return startCall(for: request, method: service.createAnonymous, responseMap: { AccessToken($0.accessToken) }, completion: completion)
    }
}
