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
            delegate?.providersDidChange(self)
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
        if _providers != nil {
            delegate?.providersDidChange(self)
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
                strongSelf.delegate?.providersDidReceiveError(strongSelf, error: error)
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
    
    var providerGroupsByGroupedName: [ProviderGroupedByGroupedName] {
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupedName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroupsByGroupedNames = [ProviderGroupedByGroupedName]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupedName == groupName })
            providerGroupsByGroupedNames.append(ProviderGroupedByGroupedName(providers: providersWithSameGroupedName))
            
        }
        return providerGroupsByGroupedNames.sorted(by: { $0.providers.count < $1.providers.count })
    }
}

protocol ProviderStoreDelegate: AnyObject {
    func providersDidChange(_ context: ProviderStore)
    func providersDidReceiveError(_ context: ProviderStore, error: Error)
}
