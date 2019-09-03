protocol ProviderMarketContextDelegate: AnyObject {
    func providerMarketContext(_ store: ProviderMarketContext, didUpdateMarkets markets: [Market])
    func providerMarketContext(_ store: ProviderMarketContext, didReceiveError error: Error)
}

class ProviderMarketContext {
    private let providerStore = ProviderStore.shared
    init() {
        providerStore.addMarketsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf._markets = strongSelf.providerStore.markets
        }
    }
    
    weak var delegate: ProviderMarketContextDelegate?
    private let storeObserverToken = StoreObserverToken()
    private var _markets: [Market]? {
        didSet {
            guard let markets = _markets else { return }
            delegate?.providerMarketContext(self, didUpdateMarkets: markets)
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

extension ProviderMarketContext {
    var market: [Market] {
        guard let markets = _markets else {
            performFetch()
            return []
        }
        return markets
    }
}
