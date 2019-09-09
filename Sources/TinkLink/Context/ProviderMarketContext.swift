public protocol ProviderMarketContextDelegate: AnyObject {
    func providerMarketContext(_ store: ProviderMarketContext, didUpdateMarkets markets: [Market])
    func providerMarketContext(_ store: ProviderMarketContext, didReceiveError error: Error)
}

public class ProviderMarketContext {
    public init() {
        _markets = providerStore.markets?.sortedWithCurrentRegionFirst()
        providerStore.addMarketsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf._markets = strongSelf.providerStore.markets?.sortedWithCurrentRegionFirst() ?? []
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
    public var markets: [Market] {
        guard let markets = _markets else {
            performFetch()
            return []
        }
        return markets
    }
}
