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

    private let authenticationManager: AuthenticationManager
    private let market: Market
    private let locale: Locale
    private var service: CredentialService
    private var createCredentialRetryCancellable: [Provider.ID: RetryCancellable] = [:]
    private var fetchCredentialsRetryCancellable: RetryCancellable?
    private let tinkQueue = DispatchQueue(label: "com.tink.TinkLink.CredentialStore", attributes: .concurrent)

    init(tinkLink: TinkLink) {
        self.service = tinkLink.client.credentialService
        self.market = tinkLink.client.market
        self.locale = tinkLink.client.locale
        self.authenticationManager = tinkLink.authenticationManager
    }

    func addCredential(for provider: Provider, fields: [String: String], appURI: URL, completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable {
        let multiHandler = MultiHandler()
        let market = Market(code: provider.marketCode)

        let authHandler = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self] _ in
            guard let self = self, self.createCredentialRetryCancellable[provider.id] == nil else { return }
            let handler = self.service.createCredential(providerID: provider.id, fields: fields, appURI: appURI, completion: { result in
                self.tinkQueue.async(qos: .default, flags: .barrier) {
                    do {
                        let credential = try result.get()
                        self._credentials[credential.id] = credential
                        completion(.success(credential))
                    } catch {
                        completion(.failure(error))
                    }
                }
                self.createCredentialRetryCancellable[provider.id] = nil
            })
            self.createCredentialRetryCancellable[provider.id] = handler
            multiHandler.add(handler)
        }
        if let handler = authHandler {
            multiHandler.add(handler)
        }
        return multiHandler
    }

    func update(credential: Credential) {
        _credentials[credential.id] = credential
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
