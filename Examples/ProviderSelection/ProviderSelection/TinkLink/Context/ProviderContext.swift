protocol providerContextDelegate: AnyObject {
    func providerContext(_ store: ProviderContext, didUpdateProviders providers: [Provider])
    func providerContext(_ store: ProviderContext, didReceiveError error: Error)
}

public class ProviderContext {
    var market: String
    private let storeObserverToken = StoreObserverToken()
    private let providerStore = ProviderStore.shared
    init(market: String) {
        self.market = market
        providerStore.addProvidersObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf._providers = strongSelf.providerStore.providerMarketGroups[market]
        }
    }
    
    private var _providers: [Provider]? {
        didSet {
            guard let providers = _providers else { return }
            delegate?.providerContext(self, didUpdateProviders: providers)
        }
    }
    
    weak var delegate: providerContextDelegate? {
        didSet {
            if delegate != nil {
                performFetch()
            }
        }
    }
    
    func performFetch() {
        if let providers = providerStore.providerMarketGroups[market] {
            _providers = providers
        } else {
            providerStore.performFetchProvidersIfNeeded(for: market)
        }
    }
}

extension ProviderContext {
    var providers: [Provider] {
        guard let providers = _providers else {
            performFetch()
            return []
        }
        return providers
    }
    
    var providerGroups: [ProviderGroup] {
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupedName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroupsByGroupedNames = [ProviderGroup]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupedName == groupName })
            providerGroupsByGroupedNames.append(ProviderGroup(providers: providersWithSameGroupedName))
            
        }
        return providerGroupsByGroupedNames.sorted(by: { $0.providers.count < $1.providers.count })
    }
}
