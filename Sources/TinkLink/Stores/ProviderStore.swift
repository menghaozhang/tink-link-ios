import Foundation
// Mocked Provider store
final class ProviderStore {
    static let shared: ProviderStore = ProviderStore()
    private init() {
        service = TinkLink.shared.client.providerService
    }
    private var service: ProviderService
    private var marketCallerCanceller: Cancellable?
    private var providerCallerCancellers: [Market: Cancellable?] = [:]
var providerMarketGroups: [Market: [Provider]] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.providerStoreObservers.forEach({ (tokenID, handler) in
                    handler(tokenID)
                })
            }
        }
    }
    var markets: [Market]? {
        didSet {
            guard let markets = markets, !markets.isEmpty else { return }
            DispatchQueue.main.async {
                self.providerStoreMarketObservers.forEach { (tokenID, handler) in
                    handler(tokenID)
                }
            }
        }
    }
    
    func performFetchProvidersIfNeeded(for market: Market) {
        guard providerCallerCancellers[market] == nil else {
            return
        }
        let cancellable = service.providers(market: market, includeTestProviders: true) { [weak self, market] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedProviders):
                    strongSelf.providerMarketGroups[market] = fetchedProviders
                case .failure:
                    break
                    //error
                }
                strongSelf.providerCallerCancellers[market] = nil
            }
        }
        providerCallerCancellers[market] = cancellable
    }
    
    func performFetchMarketsIfNeeded() {
        guard marketCallerCanceller == nil else {
            return
        }
        let cancellable = service.providerMarkets { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let markets):
                    strongSelf.markets = markets
                case .failure:
                    break
                    //error
                }
                strongSelf.marketCallerCanceller = nil
            }
        }
        marketCallerCanceller = cancellable
    }
    
    // TODO: Abstract this part
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
