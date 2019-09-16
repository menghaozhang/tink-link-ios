import Foundation

final class ProviderStore {
    static let shared: ProviderStore = ProviderStore()

    private init() {
        service = TinkLink.shared.client.providerService
        if UserStore.shared.accessToken == nil {
            dispatchGroup.enter()
            UserStore.shared.fetchAccessToken { [weak self] _ in
                self?.dispatchGroup.leave()
            }
        }
    }
    private let dispatchGroup = DispatchGroup()
    private var service: ProviderService
    private var marketFetchCanceller: Cancellable?
    private var providerFetchCancellers: [ProviderContext.Attributes: Cancellable] = [:]

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
        dispatchGroup.notify(queue: .main) {
            guard self.providerFetchCancellers[attributes] == nil else {
                return
            }
            let cancellable = self.service.providers(market: attributes.market, capabilities: attributes.capabilities, includeTestProviders: attributes.includeTestProviders) { [weak self, attributes] result in
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
                    self.providerFetchCancellers[attributes] = nil
                }
            }
            self.providerFetchCancellers[attributes] = cancellable
        }
    }
    
    func performFetchMarketsIfNeeded() {
        dispatchGroup.notify(queue: .main) {
            guard self.marketFetchCanceller == nil else {
                return
            }
            let cancellable = self.service.providerMarkets { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.markets = [Market(code: "SE"), Market(code: "NO")]
                    //                switch result {
                    //                case .success(let markets):
                    //                    self.markets = markets
                    //                case .failure:
                    //                    break
                    //                    //error
                    //                }
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
