import SwiftGRPC

class ProviderService: TokenConfigurableService {
    let channel: Channel
    let metadata: Metadata

    var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                try? metadata.addAccessToken(accessToken.rawValue)
            }
        }
    }

    convenience init(tinkLink: TinkLink = .shared, accessToken: AccessToken? = nil) {
        let metadata = tinkLink.client.metadata.copy()
        if let accessToken = accessToken {
            try? metadata.addAccessToken(accessToken.rawValue)
        }
        self.init(channel: tinkLink.client.channel, metadata: metadata)
        self.accessToken = accessToken
    }

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    internal lazy var service = ProviderServiceServiceClient(channel: channel, metadata: metadata)

    /// Lists all providers
    ///
    /// - Parameters:
    ///   - market: The market to fetch providers for. If no market is specified the providers for the users current market will be requested.
    ///   - capabilities: Use the capability to only list providers with a specific capability. If no capability the provider response will not be filtered on capability.
    ///   - includeTestProviders: If set to true, Providers of TEST financial financial institution kind will be added in the response list. Defaults to false.
    ///   - completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func providers(market: Market? = nil, capabilities: Provider.Capabilities = .all, includeTestProviders: Bool = false, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable {
        var request = GRPCProviderListRequest()
        request.marketCode = market?.code ?? ""
        request.capability = .unknown
        request.includeTestType = includeTestProviders

        return CallHandler(for: request, method: service.listProviders, responseMap: { $0.providers.map { Provider(grpcProvider: $0) }.filter { !$0.capabilities.isDisjoint(with: capabilities) } }, completion: completion)
    }

    /// Lists all markets where there are providers available.
    ///
    /// - Parameter completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func providerMarkets(completion: @escaping (Result<[Market], Error>) -> Void) -> RetryCancellable {
        let request = GRPCProviderMarketListRequest()

        return CallHandler(for: request, method: service.listProviderMarkets, responseMap: { $0.providerMarkets.map { Market(code: $0.code) } }, completion: completion)
    }
}
