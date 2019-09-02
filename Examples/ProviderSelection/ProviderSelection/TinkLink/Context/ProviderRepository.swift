protocol ProviderRepositoryDelegate: AnyObject {
    func providerRepository(_ store: ProviderRepository, didUpdateProviders providers: [Provider])
    func providerRepository(_ store: ProviderRepository, didReceiveError error: Error)
}

public class ProviderRepository {
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
    
    enum ProvidersStatus {
        case loading
        case cached([Provider])
        case loaded([Provider])
        case error(Error)
    }
    
    private var _providersStatus: ProvidersStatus? {
        didSet {
            guard let providersStatus = _providersStatus else { return }
            switch providersStatus {
            case .cached(let providers), .loaded(let providers):
                _providers = providers
            case .error(let error):
                delegate?.providerRepository(self, didReceiveError: error)
            default:
                break
            }
        }
    }
    
    private var _providers: [Provider]? {
        didSet {
            guard let providers = _providers else { return }
            delegate?.providerRepository(self, didUpdateProviders: providers)
        }
    }
    
    weak var delegate: ProviderRepositoryDelegate? {
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

extension ProviderRepository {
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
