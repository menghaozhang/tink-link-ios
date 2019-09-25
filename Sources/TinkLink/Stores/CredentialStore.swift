import Foundation
import SwiftGRPC

final class CredentialStore {
    var credentials: [Identifier<Credential>: Credential] = [:] {
        didSet {
            NotificationCenter.default.post(name: .credentialStoreChanged, object: self)
        }
    }
    private let authenticationManager: AuthenticationManager
    private let market: Market
    private let locale: Locale
    private var service: CredentialService
    private var createCredentialRetryCancellable: [Identifier<Provider>: RetryCancellable] = [:]
    private var credentialStatusPollingRetryCancellable: [Identifier<Credential>: RetryCancellable] = [:]
    private var addSupplementalInformationRetryCancellable: [Identifier<Credential>: RetryCancellable] = [:]
    private var cancelSupplementInformationRetryCancellable: [Identifier<Credential>: RetryCancellable] = [:]
    private var fetchCredentialsRetryCancellable: RetryCancellable?
    
    init(tinkLink: TinkLink) {
        service = tinkLink.client.credentialService
        market = tinkLink.client.market
        locale = tinkLink.client.locale
        authenticationManager = AuthenticationManager.shared
    }
    
    func addCredential(for provider: Provider, fields: [String: String], completion: @escaping(Result<Credential, Error>) -> Void) -> RetryCancellable {
        var multiHandler = MultiHandler()
        let market = Market(code: provider.marketCode)
        let authHandler = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self] _ in
            guard let self = self, self.createCredentialRetryCancellable[provider.name] == nil else { return }
            let handler = self.service.createCredential(providerName: provider.name, fields: fields, completion: { (result) in
                DispatchQueue.main.async {
                    do {
                        let credential = try result.get()
                        completion(.success(credential))
                        self.credentials[credential.id] = credential
                    } catch let error {
                        completion(.failure(error))
                    }
                    self.createCredentialRetryCancellable[provider.name] = nil
                }
            })
            self.createCredentialRetryCancellable[provider.name] = handler
            multiHandler.add(handler)
        }
        if let handler = authHandler {
            multiHandler.add(handler)
        }
        return multiHandler
    }
    
    /// - Precondition: Service should be configured with access token before this method is called.
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) {
        precondition(service.metadata.hasAuthorization, "Service doesn't have authentication metadata set!")
        addSupplementalInformationRetryCancellable[credential.id] = self.service.supplementInformation(credentialID: credential.id, fields: supplementalInformationFields) { [weak self] result in
            DispatchQueue.main.async {
                self?.addSupplementalInformationRetryCancellable[credential.id] = nil
                completion(result)
            }
        }
    }
    
    /// - Precondition: Service should be configured with access token before this method is called.
    func cancelSupplementInformation(for credential: Credential, completion: @escaping (Result<Void, Error>) -> Void) {
        precondition(service.metadata.hasAuthorization, "Service doesn't have authentication metadata set!")
        cancelSupplementInformationRetryCancellable[credential.id] = self.service.cancelSupplementInformation(credentialID: credential.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.cancelSupplementInformationRetryCancellable[credential.id] = nil
                completion(result)
            }
        }
    }

    func performFetchIfNeeded() {
        if fetchCredentialsRetryCancellable == nil {
            performFetch()
        }
    }

    func performFetch() {
        fetchCredentialsRetryCancellable = service.credentials { [weak self] result in
            DispatchQueue.main.async {
                self?.fetchCredentialsRetryCancellable = nil
                do {
                    let credentials = try result.get()
                    self?.credentials = Dictionary(grouping: credentials, by: { $0.id })
                        .compactMapValues { $0.first }
                } catch {
                    NotificationCenter.default.post(name: .credentialStoreErrorOccured, object: self, userInfo: [CredentialStoreErrorOccuredNotificationErrorKey: error])
                }
            }
        }
    }
}

extension Notification.Name {
    static let credentialStoreChanged = Notification.Name("TinkLinkCredentialStoreChangedNotificationName")
    static let credentialStoreErrorOccured = Notification.Name("TinkLinkCredentialStoreErrorOccuredNotificationName")
}

/// User info key for credentialStoreErrorOccured notification.
let CredentialStoreErrorOccuredNotificationErrorKey = "error"
