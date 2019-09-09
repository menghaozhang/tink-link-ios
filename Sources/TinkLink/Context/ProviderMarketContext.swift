public protocol ProviderMarketContextDelegate: AnyObject {
    func providerMarketContext(_ store: ProviderMarketContext, didUpdateMarkets markets: [Market])
    func providerMarketContext(_ store: ProviderMarketContext, didReceiveError error: Error)
}

public class ProviderMarketContext {
    public init() {
        var markets = providerStore.markets?.sorted() ?? []
        providerStore.addMarketsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            var markets = strongSelf.providerStore.markets?.sorted() ?? []
            if let currentRegionCode = Locale.current.regionCode, let index = markets.firstIndex(of: Market(code: currentRegionCode)) {
                let currentMarket = markets.remove(at: index)
                markets.insert(currentMarket, at: 0)
            }
            strongSelf._markets = markets
        }
    }
    
    public weak var delegate: ProviderMarketContextDelegate?
    
    private let providerStore = ProviderStore.shared
    private let storeObserverToken = StoreObserverToken()

    private var _markets: [Market]? {
        didSet {
            guard let markets = _markets else { return }
            delegate?.providerMarketContext(self, didUpdateMarkets: markets)
        }
    }
    
    private func performFetch() {
        providerStore.performFetchMarketsIfNeeded()
    }
}

// Markets
extension ProviderMarketContext {
    public var market: [Market] {
        guard let markets = _markets else {
            performFetch()
            return []
        }
        return markets
    }
}
