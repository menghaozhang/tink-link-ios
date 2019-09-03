protocol ProviderMarketRepositoryDelegate: AnyObject {
    func providerMarketRepository(_ store: ProviderMarketRepository, didUpdateMarkets markets: [String])
    func providerMarketRepository(_ store: ProviderMarketRepository, didReceiveError error: Error)
}

class ProviderMarketRepository {
    private let providerStore = ProviderStore.shared
    init() {
        providerStore.addMarketsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf._markets = strongSelf.providerStore.markets
        }
    }
    
    weak var delegate: ProviderMarketRepositoryDelegate?
    private let storeObserverToken = StoreObserverToken()
    private var _markets: [String]? {
        didSet {
            guard let markets = _markets else { return }
            delegate?.providerMarketRepository(self, didUpdateMarkets: markets)
        }
    }
    
    func performFetch() {
        if let markets = providerStore.markets {
            _markets = markets
        } else {
            providerStore.performFetchMarketsIfNeeded()
        }
    }
}

extension ProviderMarketRepository {
    var market: [String] {
        guard let markets = _markets else {
            performFetch()
            return []
        }
        return markets
    }
}
