import Foundation

public protocol ProviderContextDelegate: AnyObject {
    func providerContextWillChangeProviders(_ context: ProviderContext)
    func providerContext(_ context: ProviderContext, didReceiveError error: Error)
    func providerContextDidChangeProviders(_ context: ProviderContext)
}

extension ProviderContextDelegate {
    public func providerContextWillChangeProviders(_ context: ProviderContext) { }
}

/// An object that accesses providers for a specific market and supports the grouping of providers.
public class ProviderContext {
    /// Attributes representing which providers a context should access.
    public struct Attributes: Hashable {
        public let capabilities: Provider.Capabilities
        public let includeTestProviders: Bool
        public let accessTypes: Set<Provider.AccessType>
        public let market: Market
        public let locale: Locale
        
        public init(capabilities: Provider.Capabilities, includeTestProviders: Bool, accessTypes: Set<Provider.AccessType>, market: Market, locale: Locale) {
            self.capabilities = capabilities
            self.includeTestProviders = includeTestProviders
            self.accessTypes = accessTypes
            self.market = market
            self.locale = locale
        }
    }
    
    /// Attributes representing which providers a context should access.
    ///
    /// Changing this property will update `providers` and `providerGroups` to only access providers matching the new attributes.
    public var attributes: ProviderContext.Attributes {
        didSet {
            providerStore.performFetchProvidersIfNeeded(for: attributes)
        }
    }

    private let providerStore = ProviderStore.shared
    private var providerStoreObserver: Any?

    private var _providers: [Provider]? {
        willSet {
            delegate?.providerContextWillChangeProviders(self)
        }
        didSet {
            _providerGroups = _providers.map(makeGroups)
            delegate?.providerContextDidChangeProviders(self)
        }
    }
    
    private var _providerGroups: [ProviderGroup]?

    public weak var delegate: ProviderContextDelegate? {
        didSet {
            if delegate != nil, _providers == nil {
                performFetch()
            }
        }
    }
    
    /// A convenience initializer that accesses providers from a market including all capabilities and access types but no test providers.
    ///
    /// - Parameter market: Market to access.
    public convenience init(market: Market) {
        let locale = Locale.tink.availableLocalesGroupedByRegionCode[market.code] ?? Locale(identifier: "sv_SE")
        let attributes = Attributes(capabilities: .all, includeTestProviders: false, accessTypes: Provider.AccessType.all, market: market, locale: locale)
        self.init(attributes: attributes)
    }
    
    public init(attributes: Attributes) {
        self.attributes = attributes
        _providers = try? providerStore.providerMarketGroups[attributes.market]?.get()
        _providerGroups = _providers.map{ makeGroups($0) }
        providerStoreObserver = NotificationCenter.default.addObserver(forName: .providerStoreMarketGroupsChanged, object: providerStore, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            do {
                self._providers = try self.providerStore.providerMarketGroups[attributes.market]?.get()
            } catch {
                self.delegate?.providerContext(self, didReceiveError: error)
            }
        }
    }
    
    // TODO: performFetch is triggered multiple times
    private func performFetch() {
        providerStore.performFetchProvidersIfNeeded(for: attributes)
    }
    
    private func makeGroups(_ providers: [Provider]) -> [ProviderGroup] {
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
        guard let providerGroups = _providerGroups else {
            performFetch()
            return []
        }
        return providerGroups
    }
    
    public func search(_ query: String) -> [ProviderGroup] {
        if query.isEmpty {
            return providerGroups
        }
        
        return providerGroups.filter({ $0.groupedDisplayName?.localizedCaseInsensitiveContains(query) ?? false })
    }
}
