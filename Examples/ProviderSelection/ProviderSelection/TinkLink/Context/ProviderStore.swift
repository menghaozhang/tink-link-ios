import Foundation
// Mocked Provider store
class ProviderStore {
    static let shared: ProviderStore = ProviderStore()
    private init() {
        service = ProviderService(client: TinkLink.shared.client)
    }
    private var service: ProviderService
    var providerMarketGroups: [String: [Provider]] = [:]
    var markets: [String]? {
        didSet {
            guard let markets = markets else { return }
            providerStoreMarketObservers.forEach { (id, handler) in
                handler(id, markets)
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
                strongSelf.providerStoreObservers.forEach({ (id, handler) in
                    handler(id, fetchedProviders)
                })
            case .failure(let error):
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
            case .failure(let error):
                break
                //error
            }
        }
    }
    
    // Provider Observer
    typealias ProviderStoreObserverHandler = (_ tokenIdentifier: UUID, _ providers: [Provider]) -> Void
    var providerStoreObservers: [UUID: ProviderStoreObserverHandler] = [:]
    func addProvidersObserver(token: StoreObserverToken, handler: @escaping ProviderStoreObserverHandler) {
        token.addReleaseHandler { [weak self] in
            self?.providerStoreObservers[token.identifier] = nil
        }
        providerStoreObservers[token.identifier] = handler
    }
    
    // Market Observer
    typealias ProviderStoreMarketObserverHandler = (_ tokenIdentifier: UUID, _ markets: [String]) -> Void
    var providerStoreMarketObservers: [UUID: ProviderStoreMarketObserverHandler] = [:]
    func addMarketsObserver(token: StoreObserverToken, handler: @escaping ProviderStoreMarketObserverHandler) {
        token.addReleaseHandler { [weak self] in
            self?.providerStoreObservers[token.identifier] = nil
        }
        providerStoreMarketObservers[token.identifier] = handler
    }
}

final class StoreObserverToken {
    fileprivate let identifier = UUID()
    private var releaseHandlers = [() -> Void]()
    
    init() {}
    
    func match(id: UUID) -> Bool {
        return identifier == id
    }
    
    func addReleaseHandler(releaseHandler: @escaping () -> Void) {
        releaseHandlers.append(releaseHandler)
    }
    
    deinit {
        releaseHandlers.forEach { $0() }
    }
}
