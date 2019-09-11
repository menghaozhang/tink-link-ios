import Foundation

final class ProviderStore {
    static let shared: ProviderStore = ProviderStore()

    private init() {
        service = TinkLink.shared.client.providerService
    }

    private var service: ProviderService
    private var marketFetchCanceller: Cancellable?
    private var providerFetchCancellers: [UUID: Cancellable?] = [:]

    var providerMarketGroups: [Market: [Provider]] = [:] {
        didSet {
            NotificationCenter.default.post(name: .providerStoreMarketGroupsChanged, object: self)
        }
    }
    
    var markets: [Market]? {
        didSet {
            NotificationCenter.default.post(name: .providerStoreMarketsChanged, object: self)
        }
    }
    
    func performFetchProvidersIfNeeded(for attributes: ProviderContext.Attributes) {
        guard providerFetchCancellers[attributes.id] == nil else {
            return
        }
        let cancellable = service.providers(market: attributes.market, capabilities: attributes.capabilities, includeTestProviders: attributes.includeTestProviders) { [weak self, attributes] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedProviders):
                    let filteredProviders = fetchedProviders.filter({ attributes.accessTypes.contains($0.accessType) })
                    self.providerMarketGroups[attributes.market] = filteredProviders
                case .failure:
                    break
                    //error
                }
                self.providerFetchCancellers[attributes.id] = nil
            }
        }
        providerFetchCancellers[attributes.id] = cancellable
    }
    
    func performFetchMarketsIfNeeded() {
        guard marketFetchCanceller == nil else {
            return
        }
        let cancellable = service.providerMarkets { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let markets):
                    self.markets = markets
                case .failure:
                    break
                    //error
                }
                self.marketFetchCanceller = nil
            }
        }
        marketFetchCanceller = cancellable
    }
}

extension Notification.Name {
    static let providerStoreMarketGroupsChanged = Notification.Name("TinkLinkProviderStoreMarketGroupsChangedNotificationName")
    static let providerStoreMarketsChanged = Notification.Name("TinkLinkProviderStoreMarketsChangedNotificationName")
}
