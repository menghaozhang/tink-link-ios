import Foundation
import SwiftGRPC

final class ProviderStore {
    init() {

    }

    private let tinkQueue = DispatchQueue(label: "com.tink.TinkLink.ProviderStore", attributes: .concurrent)
    private var _providers: [Provider.ID: Provider]? {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .providerStoreChanged, object: self)
            }
        }
    }

    var providers: [Provider]? {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        if let providers = tinkQueue.sync(execute: { _providers }) {
            return Array(providers.values)
        }
        return nil
    }

    subscript(market: Market) -> [Provider]? {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        // TODO: This will not work when having multi market, need to store provider by market
        if let providers = tinkQueue.sync(execute: { _providers?.values.filter({ $0.marketCode == market.code }) }) {
            return providers
        }
        return nil
    }

    func store(_ providers: [Provider]) {
        tinkQueue.async(qos: .default, flags: .barrier) {
            let newProviders = Dictionary(grouping: providers, by: { $0.id })
                .compactMapValues { $0.first }
            if self._providers == nil {
                self._providers = newProviders
            } else {
            self._providers?.merge(newProviders, uniquingKeysWith: { (_, new) in new })
            }
        }
    }
}

extension Notification.Name {
    static let providerStoreChanged = Notification.Name("TinkLinkProviderStoreChangedNotificationName")
}
