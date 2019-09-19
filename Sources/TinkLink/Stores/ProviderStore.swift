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
    private var marketFetchCanceller: Cancellable?
    private var providerFetchCancellers: [ProviderContext.Attributes: Cancellable] = [:]

    var providerMarketGroups: [Market: Result<[Provider], Error>] = [:] {
        didSet {
            NotificationCenter.default.post(name: .providerStoreMarketGroupsChanged, object: self)
        }
    }
    
    var markets: Result<[Market], Error>? {
        didSet {
            NotificationCenter.default.post(name: .providerStoreMarketsChanged, object: self)
        }
    }

    func cancelFetchingProviders(for attributes: ProviderContext.Attributes) {
        providerFetchCancellers[attributes]?.cancel()
    }

    func performFetchProvidersIfNeeded(for attributes: ProviderContext.Attributes) {
        if providerFetchCancellers[attributes] != nil { return }
        providerFetchCancellers[attributes] = performFetchProviders(for: attributes)
    }

    private func performFetchProviders(for attributes: ProviderContext.Attributes) -> Cancellable {
        var multiCanceller = MultiCanceller()
        
        let authCanceller = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self, attributes] authenticationResult in
            guard let self = self, !multiCanceller.isCancelled else { return }
            do {
                try authenticationResult.get()
                let cancellable = unauthenticatedPerformFetchProviders(attributes: attributes)
                multiCanceller.add(cancellable)
            } catch {
                self.providerMarketGroups[attributes.market] = .failure(error)
                self.providerFetchCancellers[attributes] = nil
            }
        }
        if let canceller = authCanceller {
            multiCanceller.add(canceller)
        }

        return multiCanceller
    }

    private func unauthenticatedPerformFetchProviders(attributes: ProviderContext.Attributes) -> Cancellable {
        return service.providers(market: attributes.market, capabilities: attributes.capabilities, includeTestProviders: attributes.includeTestProviders) { [weak self, attributes] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                do {
                    let fetchedProviders = try result.get()
                    let filteredProviders = fetchedProviders.filter({ attributes.accessTypes.contains($0.accessType) })
                    self.providerMarketGroups[attributes.market] = .success(filteredProviders)
                } catch {
                    self.providerMarketGroups[attributes.market] = .failure(error)
                }
                self.providerFetchCancellers[attributes] = nil
            }
        }
    }
    
    func performFetchMarketsIfNeeded() {
        authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self] _ in
            guard let self = self, self.marketFetchCanceller == nil else {
                return
            }
            let cancellable = self.service.providerMarkets { result in
                DispatchQueue.main.async {
                    self.markets = result
                    self.marketFetchCanceller = nil
                }
            }
            self.marketFetchCanceller = cancellable
        }
    }
}

extension Notification.Name {
    static let providerStoreMarketGroupsChanged = Notification.Name("TinkLinkProviderStoreMarketGroupsChangedNotificationName")
    static let providerStoreMarketsChanged = Notification.Name("TinkLinkProviderStoreMarketsChangedNotificationName")
}
