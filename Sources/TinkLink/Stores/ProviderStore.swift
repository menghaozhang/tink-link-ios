import Foundation
import SwiftGRPC

final class ProviderStore {
    init() {

    }

    private let tinkQueue = DispatchQueue(label: "com.tink.TinkLink.ProviderStore", attributes: .concurrent)
    private var _providerMarketGroups: [Market: [Provider]] = [:] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .providerStoreMarketGroupsChanged, object: self)
            }
        }
    }

    var providerMarketGroups: [Market: [Provider]] {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        let providerMarketGroups = tinkQueue.sync { _providerMarketGroups }
        return providerMarketGroups
    }

    func update(_ providers: [Provider], for market: Market) {
        tinkQueue.async(qos: .default, flags: .barrier) {
            self._providerMarketGroups[market] = providers
        }
    }
}

extension Notification.Name {
    static let providerStoreMarketGroupsChanged = Notification.Name("TinkLinkProviderStoreMarketGroupsChangedNotificationName")
}
