import Foundation
import SwiftGRPC

final class ProviderStore {
    init(tinkLink: TinkLink) {
        service = tinkLink.client.providerService
        market = tinkLink.client.market
        locale = tinkLink.client.locale
        authenticationManager = AuthenticationManager.shared
    }
    private let authenticationManager: AuthenticationManager
    private let market: Market
    private let locale: Locale
    private var service: ProviderService
    private var marketFetchHandler: RetryCancellable?
    private var providerFetchHandlers: [ProviderContext.Attributes: RetryCancellable] = [:]
    private let tinkQueue = DispatchQueue(label: "tink_provider_store")
    private var _providerMarketGroups: [Market: Result<[Provider], Error>] = [:] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .providerStoreMarketGroupsChanged, object: self)
            }
        }
    }
    var providerMarketGroups: [Market: Result<[Provider], Error>] {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        let providerMarketGroups = tinkQueue.sync(flags: .barrier) { return _providerMarketGroups }
        return providerMarketGroups
    }
    
    private(set) var markets: Result<[Market], Error>? {
        didSet {
            NotificationCenter.default.post(name: .providerStoreMarketsChanged, object: self)
        }
    }

    func cancelFetchingProviders(for attributes: ProviderContext.Attributes) {
        providerFetchHandlers[attributes]?.cancel()
    }

    func performFetchProvidersIfNeeded(for attributes: ProviderContext.Attributes) {
        if providerFetchHandlers[attributes] != nil { return }
        providerFetchHandlers[attributes] = performFetchProviders(for: attributes)
    }

    private func performFetchProviders(for attributes: ProviderContext.Attributes) -> RetryCancellable {
        var multiHandler = MultiHandler()
    
        let authCanceller = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self, attributes] authenticationResult in
            guard let self = self, !multiHandler.isCancelled else { return }
            do {
                try authenticationResult.get()
                let RetryCancellable = self.unauthenticatedPerformFetchProviders(attributes: attributes)
                multiHandler.add(RetryCancellable)
            } catch {
                self.tinkQueue.async {
                    self._providerMarketGroups[self.market] = .failure(error)
                }
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
        return service.providers(market: market, capabilities: attributes.capabilities, includeTestProviders: attributes.includeTestProviders) { [weak self, attributes] result in
            guard let self = self else { return }
            self.tinkQueue.async {
                do {
                    let fetchedProviders = try result.get()
                    let filteredProviders = fetchedProviders.filter { attributes.accessTypes.contains($0.accessType) }
                    self._providerMarketGroups[self.market] = .success(filteredProviders)
                } catch {
                    self._providerMarketGroups[self.market] = .failure(error)
                }
            }
            self.providerFetchHandlers[attributes] = nil
        }
    }
    
    func performFetchMarketsIfNeeded() {
        if marketFetchHandler != nil { return }
        self.marketFetchHandler = performFetchMarkets()
    }

    private func performFetchMarkets() -> RetryCancellable {
        var multiHandler = MultiHandler()
        let authHandler = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self] _ in
            guard let self = self, self.marketFetchHandler == nil else { return }
            let retryCancellable = self.service.providerMarkets { result in
                self.tinkQueue.async {
                    self.markets = result
                }
                self.marketFetchHandler = nil
            }
            multiHandler.add(retryCancellable)
        }
        if let handler = authHandler {
            multiHandler.add(handler)
        }
        return multiHandler
    }
}

extension Notification.Name {
    static let providerStoreMarketGroupsChanged = Notification.Name("TinkLinkProviderStoreMarketGroupsChangedNotificationName")
    static let providerStoreMarketsChanged = Notification.Name("TinkLinkProviderStoreMarketsChangedNotificationName")
}
