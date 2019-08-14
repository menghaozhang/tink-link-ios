import SwiftGRPC

public final class ProviderService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service = ProviderServiceServiceClient(channel: channel)

    func providers(marketCode: String = "", capability: GRPCProvider.Capability = .unknown, includeTestType: Bool = false, completion: @escaping (Result<[GRPCProvider], Error>) -> Void) -> Cancellable {
        var request = GRPCProviderListRequest()
        request.marketCode = marketCode
        request.capability = capability
        request.includeTestType = includeTestType

        let canceller = CallCanceller()

        do {
            canceller.call = try service.listProviders(request) { (response, result) in
                if let response = response {
                    completion(.success(response.providers))
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

    func providerMarkets(completion: @escaping (Result<[GRPCProviderMarket], Error>) -> Void) -> Cancellable {
        let request = GRPCProviderMarketListRequest()

        let canceller = CallCanceller()

        do {
            canceller.call = try service.listProviderMarkets(request) { (response, result) in
                if let response = response {
                    completion(.success(response.providerMarkets))
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
