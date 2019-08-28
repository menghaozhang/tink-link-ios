protocol ProviderStoreDelegate: AnyObject {
    func providerStore(_ store: ProviderStore, didUpdateProviders providers: [Provider])
    func providerStore(_ store: ProviderStore, didReceiveError error: Error)
}

// Mocked Provider store
class ProviderStore {
    var market: String
    private var service: ProviderService
    
    init(market: String) {
        self.market = market
        service = ProviderService(client: TinkLink.shared.client)
    }
    
    private var _providers: [Provider]? {
        didSet {
            guard let providers = _providers else { return }
            delegate?.providerStore(self, didUpdateProviders: providers)
        }
    }
    
    weak var delegate: ProviderStoreDelegate? {
        didSet {
            if delegate != nil {
                performFetch()
            }
        }
    }
    
    func performFetch() {
        if let providers = _providers {
            delegate?.providerStore(self, didUpdateProviders: providers)
        } else {
            performFetchIfNeeded()
        }
    }
    
    private func performFetchIfNeeded() {
        service.providers(marketCode: market) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let providers):
                self?._providers = providers
            case .failure(let error):
                strongSelf.delegate?.providerStore(strongSelf, didReceiveError: error)
            }
        }
    }
}

extension ProviderStore {
    var providers: [Provider] {
        if _providers == nil {
            performFetch()
        }
        return _providers ?? []
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
