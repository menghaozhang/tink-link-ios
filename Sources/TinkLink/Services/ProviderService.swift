import SwiftGRPC

public final class ProviderService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service = ProviderServiceServiceClient(channel: channel)

    /// Lists all providers
    ///
    /// - Parameters:
    ///   - marketCode: The market to fetch providers for. If no market is specified the providers for the users current market will be requested.
    ///   - capability: Use the capability to only list providers with a specific capability. If no capability the provider response will not be filtered on capability.
    ///   - includeTestType: If set to true, Providers of TEST type will be added in the response list. Defaults to false.
    ///   - completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
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

    /// Lists all markets where there are providers available.
    ///
    /// - Parameter completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
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
