import Foundation
import SwiftGRPC

final class ProviderStore {
    init() {

    }

    private let tinkQueue = DispatchQueue(label: "com.tink.TinkLink.ProviderStore", attributes: .concurrent)
    private var _providers: [Provider.ID: Provider] = [:] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .providerStoreChanged, object: self)
            }
        }
    }

    var providers: [Provider] {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        let providers = tinkQueue.sync { _providers }
        return Array(providers.values)
    }

    subscript(market: Market) -> [Provider] {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        let providers = tinkQueue.sync { _providers.values.filter({ $0.marketCode == market.code }) }
        return providers
    }

    func store(_ providers: [Provider]) {
        tinkQueue.async(qos: .default, flags: .barrier) {
            let newProviders = Dictionary(grouping: providers, by: { $0.id })
                .compactMapValues { $0.first }
            self._providers.merge(newProviders, uniquingKeysWith: { (_, new) in new })
        }
    }
}

extension Notification.Name {
    static let providerStoreChanged = Notification.Name("TinkLinkProviderStoreChangedNotificationName")
}
