public protocol ProviderMarketContextDelegate: AnyObject {
    func providerMarketContext(_ store: ProviderMarketContext, didUpdateMarkets markets: [Market])
    func providerMarketContext(_ store: ProviderMarketContext, didReceiveError error: Error)
}

public class ProviderMarketContext {
    public init() {
        var markets = providerStore.markets?.sorted()
        markets = markets.map(updateAccordingToCurrentRegion(for:))
        _markets = markets
        providerStore.addMarketsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            var markets = strongSelf.providerStore.markets?.sorted() ?? []
            strongSelf._markets = strongSelf.updateAccordingToCurrentRegion(for: markets)
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
    
    private func updateAccordingToCurrentRegion(for markets: [Market]) -> [Market] {
        if let currentRegionCode = Locale.current.regionCode, let index = markets.firstIndex(of: Market(code: currentRegionCode)) {
            var multableMarkets = markets
            let currentMarket = multableMarkets.remove(at: index)
            multableMarkets.insert(currentMarket, at: 0)
            return multableMarkets
        }
        return markets
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
