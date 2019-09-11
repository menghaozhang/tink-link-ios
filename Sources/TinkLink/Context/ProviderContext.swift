import Foundation

public protocol ProviderContextDelegate: AnyObject {
    func providerContext(_ context: ProviderContext, didUpdateProviders providers: [Provider])
    func providerContext(_ context: ProviderContext, didReceiveError error: Error)
}

public class ProviderContext {
    var market: Market

    private let providerStore = ProviderStore.shared
    private var providerStoreObserver: Any?

    private var _providers: [Provider]? {
        didSet {
            guard let providers = _providers else { return }
            delegate?.providerContext(self, didUpdateProviders: providers)
        }
    }

    public weak var delegate: ProviderContextDelegate? {
        didSet {
            if delegate != nil, _providers == nil {
                performFetch()
            }
        }
    }
    
    public init(market: Market) {
        self.market = market
        _providers = providerStore.providerMarketGroups[market]
        providerStoreObserver = NotificationCenter.default.addObserver(forName: .providerStoreMarketGroupsChanged, object: providerStore, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            self._providers = self.providerStore.providerMarketGroups[market]
        }
    }
    
    private func performFetch() {
        providerStore.performFetchProvidersIfNeeded(for: market)
    }
}

extension ProviderContext {
    public var providers: [Provider] {
        guard let providers = _providers else {
            performFetch()
            return []
        }
        return providers
    }
    
    public var providerGroups: [ProviderGroup] {
        guard let providers = _providers, !providers.isEmpty else {
            return []
        }
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupDisplayName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroups = [ProviderGroup]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupDisplayName == groupName })
            providerGroups.append(ProviderGroup(providers: providersWithSameGroupedName))
        }
        return providerGroups.sorted(by: { $0.groupedDisplayName ?? "" < $1.groupedDisplayName ?? "" })
    }
    public func search(_ query: String) -> [ProviderGroup] {
        guard !query.isEmpty else {
            return providerGroups
        }
        
        return providerGroups.filter({ $0.groupedDisplayName?.localizedCaseInsensitiveContains(query) ?? false })
    }
}
