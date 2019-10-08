import Foundation

/// A protocol that allows a delegate to respond to provider changes or fetching errors.
public protocol ProviderContextDelegate: AnyObject {
    /// Notifies the delegate that the providers are about to be changed.
    ///
    /// - Note: This method is optional.
    /// - Parameter context: The provider context that will change.
    func providerContextWillChangeProviders(_ context: ProviderContext)

    /// Notifies the delegate that an error occured while fetching providers.
    ///
    /// - Parameter context: The provider context that encountered the error.
    /// - Parameter error: A description of the error.
    func providerContext(_ context: ProviderContext, didReceiveError error: Error)

    /// Notifies the delegate that the providers has changed.
    ///
    /// - Parameter context: The provider context that changed.
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
        
        public init(capabilities: Provider.Capabilities, includeTestProviders: Bool, accessTypes: Set<Provider.AccessType>) {
            self.capabilities = capabilities
            self.includeTestProviders = includeTestProviders
            self.accessTypes = accessTypes
        }
    }
    
    /// Attributes representing which providers a context should access.
    ///
    /// Changing this property will update `providers` and `providerGroups` to only access providers matching the new attributes.
    public var attributes: ProviderContext.Attributes {
        didSet {
            guard attributes != oldValue else { return }
            performFetch()
        }
    }

    private let market: Market
    private let providerStore: ProviderStore
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

    /// The object that acts as the delegate of the provider context.
    ///
    /// The delegate must adopt the `ProviderContextDelegate` protocol. The delegate is not retained.
    public weak var delegate: ProviderContextDelegate? {
        didSet {
            if delegate != nil, _providers == nil {
                performFetch()
            }
        }
    }

    /// A convenience initializer that creates a context to access providers including all capabilities and access types but no test providers.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    public convenience init(tinkLink: TinkLink = .shared) {
        let attributes = Attributes(capabilities: .all, includeTestProviders: false, accessTypes: Provider.AccessType.all)
        self.init(tinkLink: tinkLink, attributes: attributes)
    }
    
    /// An initializer that provides TinkLink to config the service and attributes of accesses providers, which includs all capabilities and access types but no test providers.
    public init(tinkLink: TinkLink = .shared, attributes: Attributes) {
        providerStore = tinkLink.providerStore
        self.attributes = attributes
        self.market = tinkLink.client.market
        _providers = try? providerStore.providerMarketGroups[market]?.get()
        _providerGroups = _providers.map{ makeGroups($0) }
        providerStoreObserver = NotificationCenter.default.addObserver(forName: .providerStoreMarketGroupsChanged, object: providerStore, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            do {
                self._providers = try self.providerStore.providerMarketGroups[self.market]?.get()
            } catch {
                self.delegate?.providerContext(self, didReceiveError: error)
            }
        }
    }
    
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
    /// Providers matching the context's current attributes.
    ///
    /// - Note: The providers could be empty at first or change if the context's attributes are changed. Use the delegate to get notified when providers change.
    public var providers: [Provider] {
        guard let providers = _providers else {
            performFetch()
            return []
        }
        return providers
    }
    
    /// Grouped providers matching the context's current attributes.
    ///
    /// - Note: The providerGroups could be empty at first or change if the context's attributes are changed. Use the delegate to get notified when providerGroups change.
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
