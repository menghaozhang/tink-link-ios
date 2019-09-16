import Foundation

protocol ProviderMarketContextDelegate: AnyObject {
    func providerMarketContext(_ store: ProviderMarketContext, didUpdateMarkets markets: [Market])
    func providerMarketContext(_ store: ProviderMarketContext, didReceiveError error: Error)
}

/// An object that accesses available markets.
class ProviderMarketContext {
    init() {
        _markets = providerStore.markets?.sortedWithCurrentRegionFirst()
        NotificationCenter.default.addObserver(forName: .providerStoreMarketsChanged, object: providerStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self._markets = self.providerStore.markets?.sortedWithCurrentRegionFirst() ?? []
        }
    }

    weak var delegate: ProviderMarketContextDelegate?

    private let providerStore = ProviderStore.shared
    private var providerStoreObserver: Any?

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
    var markets: [Market] {
        guard let markets = _markets else {
            performFetch()
            return []
        }
        return markets
    }
}
