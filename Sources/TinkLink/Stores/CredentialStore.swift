import Foundation
import SwiftGRPC

final class CredentialStore {
    var credentials: [Credential.ID: Credential] {
        dispatchPrecondition(condition: .notOnQueue(tinkQueue))
        let credentials = tinkQueue.sync { _credentials }
        return credentials
    }

    private var _credentials: [Credential.ID: Credential] = [:] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .credentialStoreChanged, object: self)
            }
        }
    }

    private var service: CredentialService
    private let tinkQueue = DispatchQueue(label: "com.tink.TinkLink.CredentialStore", attributes: .concurrent)

    init(tinkLink: TinkLink) {
        self.service = tinkLink.client.credentialService
    }

    func update(credential: Credential) {
        tinkQueue.async(qos: .default, flags: .barrier) {
            self._credentials[credential.id] = credential
        }
    }

    func store(_ credentials: [Credential]) {
        tinkQueue.async(qos: .default, flags: .barrier) {
            self._credentials = Dictionary(grouping: credentials, by: { $0.id })
                .compactMapValues { $0.first }
        }
    }
}

extension Notification.Name {
    static let credentialStoreChanged = Notification.Name("TinkLinkCredentialStoreChangedNotificationName")
}
