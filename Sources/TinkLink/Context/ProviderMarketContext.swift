import Foundation

protocol ProviderMarketContextDelegate: AnyObject {
    func providerMarketContextWillChange(_ context: ProviderMarketContext)
    func providerMarketContextDidChange(_ context: ProviderMarketContext)
    func providerMarketContext(_ context: ProviderMarketContext, didReceiveError error: Error)
}

extension ProviderMarketContextDelegate {
    func providerMarketContextWillChange(_ context: ProviderMarketContext) { }
}

/// An object that accesses available markets.
class ProviderMarketContext {
    init() {
        _markets = try? providerStore.markets?.get().sortedWithCurrentRegionFirst()
        NotificationCenter.default.addObserver(forName: .providerStoreMarketsChanged, object: providerStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            do {
                self._markets = try self.providerStore.markets?.get().sortedWithCurrentRegionFirst() ?? []
            } catch {
                self.delegate?.providerMarketContext(self, didReceiveError: error)
            }
        }
    }

    weak var delegate: ProviderMarketContextDelegate?

    private let providerStore = ProviderStore.shared
    private var providerStoreObserver: Any?

    private var _markets: [Market]? {
        willSet {
            delegate?.providerMarketContextWillChange(self)
        }
        didSet {
            delegate?.providerMarketContextDidChange(self)
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
