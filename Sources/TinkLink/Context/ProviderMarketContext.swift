import Foundation

public protocol ProviderMarketContextDelegate: AnyObject {
    func providerMarketContextWillChange(_ context: ProviderMarketContext)
    func providerMarketContextDidChange(_ context: ProviderMarketContext)
    func providerMarketContext(_ context: ProviderMarketContext, didReceiveError error: Error)
}

extension ProviderMarketContextDelegate {
    public func providerMarketContextWillChange(_ context: ProviderMarketContext) { }
}

public class ProviderMarketContext {
    public init() {
        _markets = providerStore.markets?.sortedWithCurrentRegionFirst()
        NotificationCenter.default.addObserver(forName: .providerStoreMarketsChanged, object: providerStore, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self._markets = self.providerStore.markets?.sortedWithCurrentRegionFirst() ?? []
        }
    }
    
    public weak var delegate: ProviderMarketContextDelegate?
    
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
    public var markets: [Market] {
        guard let markets = _markets else {
            performFetch()
            return []
        }
        return markets
    }
}
