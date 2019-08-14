import SwiftGRPC

public final class ProviderService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service = ProviderServiceServiceClient(channel: channel)

    func providers(marketCode: String = "", capability: GRPCProvider.Capability = .unknown, includeTestType: Bool = false, completion: @escaping (Result<[GRPCProvider], Error>) -> Void) {
        var request = GRPCProviderListRequest()
        request.marketCode = marketCode
        request.capability = capability
        request.includeTestType = includeTestType

        do {
            try service.listProviders(request) { (response, result) in
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
    }

    func providerMarkets(completion: @escaping (Result<[GRPCProviderMarket], Error>) -> Void) {
        let request = GRPCProviderMarketListRequest()

        do {
            try service.listProviderMarkets(request) { (response, result) in
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
    }

}
