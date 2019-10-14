import Foundation
import SwiftGRPC

final class ProviderStore {
    init(tinkLink: TinkLink) {
        self.service = tinkLink.client.providerService
        self.market = tinkLink.client.market
        self.locale = tinkLink.client.locale
        self.authenticationManager = tinkLink.authenticationManager
    }

    private let authenticationManager: AuthenticationManager
    private let market: Market
    private let locale: Locale
    private let service: ProviderService
    private var providerFetchHandlers: [ProviderContext.Attributes: RetryCancellable] = [:]
    private let tinkQueue = DispatchQueue(label: "com.tink.TinkLink.ProviderStore", attributes: .concurrent)
    private var _providerMarketGroups: [Market: Result<[Provider], Error>] = [:] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .providerStoreMarketGroupsChanged, object: self)
            }
        }
    }

    var providerMarketGroups: [Market: Result<[Provider], Error>] {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        let providerMarketGroups = tinkQueue.sync { _providerMarketGroups }
        return providerMarketGroups
    }

    func cancelFetchingProviders(for attributes: ProviderContext.Attributes) {
        providerFetchHandlers[attributes]?.cancel()
    }

    func performFetchProvidersIfNeeded(for attributes: ProviderContext.Attributes) {
        if providerFetchHandlers[attributes] != nil { return }
        providerFetchHandlers[attributes] = performFetchProviders(for: attributes)
    }

    private func performFetchProviders(for attributes: ProviderContext.Attributes) -> RetryCancellable {
        let multiHandler = MultiHandler()

        let authCanceller = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self, attributes] authenticationResult in
            guard let self = self, !multiHandler.isCancelled else { return }
            do {
                try authenticationResult.get()
                let RetryCancellable = self.unauthenticatedPerformFetchProviders(attributes: attributes)
                multiHandler.add(RetryCancellable)
            } catch {
                self.tinkQueue.async(qos: .default, flags: .barrier) {
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
        return service.providers(market: market, capabilities: attributes.capabilities, includeTestProviders: attributes.kinds.contains(.test)) { [weak self, attributes] result in
            guard let self = self else { return }
            self.tinkQueue.async(qos: .default, flags: .barrier) {
                do {
                    let fetchedProviders = try result.get()
                    let filteredProviders = fetchedProviders.filter { attributes.accessTypes.contains($0.accessType) && attributes.kinds.contains($0.kind) }
                    self._providerMarketGroups[self.market] = .success(filteredProviders)
                } catch {
                    self._providerMarketGroups[self.market] = .failure(error)
                }
            }
            self.providerFetchHandlers[attributes] = nil
        }
    }
}

extension Notification.Name {
    static let providerStoreMarketGroupsChanged = Notification.Name("TinkLinkProviderStoreMarketGroupsChangedNotificationName")
}
