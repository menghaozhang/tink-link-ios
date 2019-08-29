protocol ProviderMarketRepositoryDelegate: AnyObject {
    func providerMarketRepository(_ store: ProviderMarketRepository, didUpdateMarkets markets: [String])
    func providerMarketRepository(_ store: ProviderMarketRepository, didReceiveError error: Error)
}

class ProviderMarketRepository {
    init() {
        ProviderStore.shared.addMarketsObserver(token: storeObserverToken) { [weak self] (tokenId, markets) in
            guard let strongSelf = self, strongSelf.storeObserverToken.match(id: tokenId) else {
                return
            }
            strongSelf._markets = markets
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
        if let markets = ProviderStore.shared.markets {
            _markets = markets
        } else {
            ProviderStore.shared.performFetchMarketsIfNeeded()
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
