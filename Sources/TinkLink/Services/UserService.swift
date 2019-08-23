import SwiftGRPC

public final class UserService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service = UserServiceServiceClient(channel: channel)

    public func createAnonymous(market: String? = nil, locale: String? = nil, origin: String? = nil, completion: @escaping (Result<String, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market ?? ""
        request.locale = locale ?? ""
        request.origin = origin ?? ""

        let canceller = CallCanceller()

        do {
            canceller.call = try service.createAnonymous(request) { (response, result) in
                if let response = response {
                    completion(.success(response.accessToken))
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
