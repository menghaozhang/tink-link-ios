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
    private var fetchCredentialsRetryCancellable: RetryCancellable?
    private let tinkQueue = DispatchQueue(label: "com.tink.TinkLink.CredentialStore", attributes: .concurrent)

    init(tinkLink: TinkLink) {
        self.service = tinkLink.client.credentialService
    }

    func update(credential: Credential) {
        tinkQueue.async(qos: .default, flags: .barrier) {
            self._credentials[credential.id] = credential
        }
    }

    func performFetchIfNeeded() {
        if fetchCredentialsRetryCancellable == nil {
            performFetch()
        }
    }

    private func performFetch() {
        fetchCredentialsRetryCancellable = service.credentials { [weak self] result in
            guard let self = self else { return }
            self.tinkQueue.async(qos: .default, flags: .barrier) {
                do {
                    let credentials = try result.get()
                    self._credentials = Dictionary(grouping: credentials, by: { $0.id })
                        .compactMapValues { $0.first }
                } catch {
                    NotificationCenter.default.post(name: .credentialStoreErrorOccured, object: self, userInfo: [CredentialStoreErrorOccuredNotificationErrorKey: error])
                }
            }
            self.fetchCredentialsRetryCancellable = nil
        }
    }
}

extension Notification.Name {
    static let credentialStoreChanged = Notification.Name("TinkLinkCredentialStoreChangedNotificationName")
    static let credentialStoreErrorOccured = Notification.Name("TinkLinkCredentialStoreErrorOccuredNotificationName")
}

/// User info key for credentialStoreErrorOccured notification.
let CredentialStoreErrorOccuredNotificationErrorKey = "error"
