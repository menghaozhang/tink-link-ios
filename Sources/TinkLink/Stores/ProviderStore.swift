import Foundation

final class ProviderStore {
    static let shared: ProviderStore = ProviderStore()

    private init() {
        service = TinkLink.shared.client.providerService
        authenticationManager = AuthenticationManager.shared
    }
    private let authenticationManager: AuthenticationManager
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

    func performFetchProvidersIfNeeded(for attributes: ProviderContext.Attributes) {
        authenticationManager.authenticateIfNeeded(service: service, for: attributes.market, locale: attributes.locale) { [weak self] _ in
            guard let self = self, self.providerFetchCancellers[attributes] == nil else {
                return
            }
            let cancellable = self.service.providers(market: attributes.market, capabilities: attributes.capabilities, includeTestProviders: attributes.includeTestProviders) { [attributes] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedProviders):
                        let filteredProviders = fetchedProviders.filter({ attributes.accessTypes.contains($0.accessType) })
                        self.providerMarketGroups[attributes.market] = .success(filteredProviders)
                    case .failure(let error):
                        self.providerMarketGroups[attributes.market] = .failure(error)
                    }
                    self.providerFetchCancellers[attributes] = nil
                }
            }
            self.providerFetchCancellers[attributes] = cancellable
        }
    }
    
    func performFetchMarketsIfNeeded() {
        authenticationManager.authenticateIfNeeded(service: service) { [weak self] _ in
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
