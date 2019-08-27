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

    public func createAnonymous(market: String? = nil, locale: String? = nil, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market ?? ""
        request.locale = locale ?? ""
        request.origin = origin ?? ""

        return startCall(for: request, method: service.createAnonymous, responseMap: { AccessToken($0.accessToken) }, completion: completion)
    }
}
