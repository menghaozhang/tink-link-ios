import Foundation
import SwiftGRPC

final class ProviderStore {
    static let shared: ProviderStore = ProviderStore()

    private init() {
        service = TinkLink.shared.client.providerService
        market = TinkLink.shared.client.market
        locale = TinkLink.shared.client.locale
        authenticationManager = AuthenticationManager.shared
    }
    private let authenticationManager: AuthenticationManager
    private let market: Market
    private let locale: Locale
    private var service: ProviderService
    private var marketFetchHandler: RetryCancellable?
    private var providerFetchHandlers: [ProviderContext.Attributes: RetryCancellable] = [:]

    private(set) var providerMarketGroups: [Market: Result<[Provider], Error>] = [:] {
        didSet {
            NotificationCenter.default.post(name: .providerStoreMarketGroupsChanged, object: self)
        }
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
                DispatchQueue.main.async {
                    self.providerMarketGroups[attributes.market] = .failure(error)
                    self.providerFetchHandlers[attributes] = nil
                }
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
        return service.providers(market: attributes.market, capabilities: attributes.capabilities, includeTestProviders: attributes.includeTestProviders) { [weak self, attributes] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let fetchedProviders = try result.get()
                    let filteredProviders = fetchedProviders.filter { attributes.accessTypes.contains($0.accessType) }
                    self.providerMarketGroups[attributes.market] = .success(filteredProviders)
                } catch {
                    self.providerMarketGroups[attributes.market] = .failure(error)
                }
                self.providerFetchHandlers[attributes] = nil
            }
        }
    }
    
    func performFetchMarketsIfNeeded() {
        if marketFetchHandler != nil { return }
        self.marketFetchHandler = performFetchMarkets()
    }

    private func performFetchMarkets() -> RetryCancellable {
        var multiHandler = MultiHandler()
        let authHandler = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self] _ in
            guard let self = self, self.marketFetchHandler == nil else {
                return
            }
            let retryCancellable = self.service.providerMarkets { result in
                DispatchQueue.main.async {
                    self.markets = result
                    self.marketFetchHandler = nil
                }
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
