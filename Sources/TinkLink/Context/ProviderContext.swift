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
    public func providerContextWillChangeProviders(_ context: ProviderContext) {}
}

/// An object that accesses providers for a specific market and supports the grouping of providers.
public class ProviderContext {
    /// Attributes representing which providers a context should access.
    public struct Attributes: Hashable {
        public let capabilities: Provider.Capabilities
        public let kinds: Set<Provider.Kind>
        public let accessTypes: Set<Provider.AccessType>

        public init(capabilities: Provider.Capabilities, kinds: Set<Provider.Kind>, accessTypes: Set<Provider.AccessType>) {
            self.capabilities = capabilities
            self.kinds = kinds
            self.accessTypes = accessTypes
        }
    }

    /// Attributes representing which providers a context should access.
    ///
    /// Changing this property will update `providers` and `providerGroups` to only access providers matching the new attributes.
    public var attributes: ProviderContext.Attributes {
        didSet {
            guard attributes != oldValue else { return }
            performFetchIfNeeded()
        }
    }

    private let market: Market
    private let providerStore: ProviderStore
    private var providerStoreObserver: Any?
    private let authenticationManager: AuthenticationManager
    private let locale: Locale
    private let service: ProviderService

    private var providerFetchHandlers: [ProviderContext.Attributes: RetryCancellable] = [:]

    private var _providerGroups: [ProviderGroup] {
        willSet {
            delegate?.providerContextWillChangeProviders(self)
        }
        didSet {
            delegate?.providerContextDidChangeProviders(self)
        }
    }

    /// The object that acts as the delegate of the provider context.
    ///
    /// The delegate must adopt the `ProviderContextDelegate` protocol. The delegate is not retained.
    public weak var delegate: ProviderContextDelegate? {
        didSet {
            if delegate != nil, _providerGroups.isEmpty {
                performFetchIfNeeded()
            }
        }
    }

    /// A convenience initializer that creates a context to access providers including all capabilities and access types but no test providers.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    public convenience init(tinkLink: TinkLink = .shared) {
        let attributes = Attributes(capabilities: .all, kinds: Provider.Kind.excludingTest, accessTypes: Provider.AccessType.all)
        self.init(tinkLink: tinkLink, attributes: attributes)
    }

    /// Creates a context to access providers that matches the provided attributes.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    /// - Parameter attributes: Attributes describing which providers the context should access.
    public init(tinkLink: TinkLink = .shared, attributes: Attributes) {
        self.providerStore = tinkLink.providerStore
        self.attributes = attributes
        self.market = tinkLink.client.market
        self.authenticationManager = tinkLink.authenticationManager
        self.service = tinkLink.client.providerService
        self.locale = tinkLink.client.locale
        let providers = providerStore[market].filter { attributes.accessTypes.contains($0.accessType) && attributes.kinds.contains($0.kind) }
        self._providerGroups = ProviderGroup.makeGroups(providers: providers)
        self.providerStoreObserver = NotificationCenter.default.addObserver(forName: .providerStoreChanged, object: providerStore, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            let providers = self.providerStore[self.market].filter { attributes.accessTypes.contains($0.accessType) && attributes.kinds.contains($0.kind) }
            self._providerGroups = ProviderGroup.makeGroups(providers: providers)
        }
    }

    private func performFetchIfNeeded() {
        performFetchProvidersIfNeeded(for: attributes)
    }
}

extension ProviderContext {
    private func cancelFetchingProviders(for attributes: ProviderContext.Attributes) {
        providerFetchHandlers[attributes]?.cancel()
    }

    private func performFetchProvidersIfNeeded(for attributes: ProviderContext.Attributes) {
        if providerFetchHandlers[attributes] != nil { return }
        providerFetchHandlers[attributes] = performFetchProviders(for: attributes)
    }

    private func performFetchProviders(for attributes: ProviderContext.Attributes) -> RetryCancellable {
        let multiHandler = MultiHandler()

        let authCanceller = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self, attributes] authenticationResult in
            guard let self = self, !multiHandler.isCancelled else { return }
            do {
                try authenticationResult.get()
                let fetchCanceller = self.unauthenticatedPerformFetchProviders(attributes: attributes)
                multiHandler.add(fetchCanceller)
            } catch {
                self.delegate?.providerContext(self, didReceiveError: error)
                self.providerFetchHandlers[attributes] = nil
            }
        }
        if let canceller = authCanceller {
            multiHandler.add(canceller)
        }

        return multiHandler
    }

    /// Requests providers for a market.
    ///
    /// - Parameter attributes: Attributes for providers to fetch
    /// - Precondition: Service should be configured with access token before this method is called.
    private func unauthenticatedPerformFetchProviders(attributes: ProviderContext.Attributes) -> RetryCancellable {
        precondition(service.metadata.hasAuthorization, "Service doesn't have authentication metadata set!")
        return service.providers(market: market, capabilities: attributes.capabilities, includeTestProviders: attributes.kinds.contains(.test)) { [weak self, attributes] result in
            guard let self = self else { return }
            do {
                let fetchedProviders = try result.get()
                let filteredProviders = fetchedProviders.filter { attributes.accessTypes.contains($0.accessType) && attributes.kinds.contains($0.kind) }
                self.providerStore.store(filteredProviders)
            } catch {
                self.delegate?.providerContext(self, didReceiveError: error)
            }
            self.providerFetchHandlers[attributes] = nil
        }
    }
}

extension ProviderContext {
    /// Grouped providers matching the context's current attributes.
    ///
    /// - Note: The providerGroups could be empty at first or change if the context's attributes are changed. Use the delegate to get notified when providerGroups change.
    public var providerGroups: [ProviderGroup] {
        if _providerGroups.isEmpty {
            performFetchIfNeeded()
            return []
        }
        return _providerGroups
    }

    public func search(_ query: String) -> [ProviderGroup] {
        if query.isEmpty {
            return providerGroups
        }

        return providerGroups.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
    }
}
