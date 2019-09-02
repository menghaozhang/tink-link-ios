import Foundation
// Mocked Provider store
class ProviderStore {
    static let shared: ProviderStore = ProviderStore()
    private init() {
        service = ProviderService(client: TinkLink.shared.client)
    }
    private var service: ProviderService
    var providerMarketGroups: [String: [Provider]] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.providerStoreObservers.forEach({ (id, handler) in
                    handler(id)
                })
            }
        }
    }
    var markets: [String]? {
        didSet {
            guard let markets = markets, !markets.isEmpty else { return }
            DispatchQueue.main.async {
                self.providerStoreMarketObservers.forEach { (tokenID, handler) in
                    handler(tokenID)
                }
            }
        }
    }
    
    func performFetchProvidersIfNeeded(for market: String?) {
        service.providers(marketCode: market) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let fetchedProviders):
                if let market = market {
                    strongSelf.providerMarketGroups[market] = fetchedProviders
                } else {
                    let groupedProviders = Dictionary(grouping: fetchedProviders, by: { $0.market })
                    strongSelf.providerMarketGroups.merge(groupedProviders, uniquingKeysWith: { (_, new) -> [Provider] in
                        return new
                    })
                }
            case .failure:
                break
                //error
            }
        }
    }
    
    func performFetchMarketsIfNeeded() {
        service.providerMarkets { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let markets):
                strongSelf.markets = markets
            case .failure:
                break
                //error
            }
        }
    }
    
    // TODO: Abustract this part
    typealias ObserverHandler = (_ tokenIdentifier: UUID) -> Void
    // Provider Observer
    var providerStoreObservers: [UUID: ObserverHandler] = [:]
    func addProvidersObserver(token: StoreObserverToken, handler: @escaping ObserverHandler) {
        token.addReleaseHandler { [weak self] in
            self?.providerStoreObservers[token.identifier] = nil
        }
        providerStoreObservers[token.identifier] = handler
    }
    
    // Market Observer
    var providerStoreMarketObservers: [UUID: ObserverHandler] = [:]
    func addMarketsObserver(token: StoreObserverToken, handler: @escaping ObserverHandler) {
        token.addReleaseHandler { [weak self] in
            self?.providerStoreMarketObservers[token.identifier] = nil
        }
        providerStoreMarketObservers[token.identifier] = handler
    }
}

final class StoreObserverToken {
    let identifier = UUID()
    private var releaseHandlers = [() -> Void]()
    
    init() {}
    
    func has(id: UUID) -> Bool {
        return identifier == id
    }
    
    func addReleaseHandler(releaseHandler: @escaping () -> Void) {
        releaseHandlers.append(releaseHandler)
    }
    
    deinit {
        releaseHandlers.forEach { $0() }
    }
}
