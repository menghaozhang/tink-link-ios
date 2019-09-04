public protocol providerContextDelegate: AnyObject {
    func providerContext(_ store: ProviderContext, didUpdateProviders providers: [Provider])
    func providerContext(_ store: ProviderContext, didReceiveError error: Error)
}

public class ProviderContext {
    var market: Market
    private let providerStore = ProviderStore.shared
    private let storeObserverToken = StoreObserverToken()
    private var _providers: [Provider]? {
        didSet {
            guard let providers = _providers else { return }
            delegate?.providerContext(self, didUpdateProviders: providers)
        }
    }
    public weak var delegate: providerContextDelegate? {
        didSet {
            if delegate != nil {
                performFetch()
            }
        }
    }
    
    public init(market: Market) {
        self.market = market
        providerStore.addProvidersObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf._providers = strongSelf.providerStore.providerMarketGroups[market]
        }
    }
    
    private func performFetch() {
        if let providers = providerStore.providerMarketGroups[market] {
            _providers = providers
        } else {
            providerStore.performFetchProvidersIfNeeded(for: market)
        }
    }
}

extension ProviderContext {
    public var providers: [Provider] {
        guard let providers = _providers else {
            performFetch()
            return []
        }
        return providers
    }
    
    public var providerGroups: [ProviderGroup] {
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupDisplayName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroups = [ProviderGroup]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupDisplayName == groupName })
            providerGroups.append(ProviderGroup(providers: providersWithSameGroupedName))
        }
        return providerGroups.sorted(by: { $0.groupedDisplayName ?? "" < $1.groupedDisplayName ?? "" })
    }
}
