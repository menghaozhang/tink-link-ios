import Foundation
import SwiftGRPC

final class CredentialStore {
    static let shared = CredentialStore()
    
    var credentials: [Identifier<Credential>: Credential] = [:] {
        didSet {
            NotificationCenter.default.post(name: .credentialStoreChanged, object: self)
        }
    }
    private let authenticationManager: AuthenticationManager
    private let market: Market
    private let locale: Locale
    private var service: CredentialService
    private var createCredentialHandler: [Identifier<Provider>: Handleable] = [:]
    private var credentialStatusPollingHandler: [Identifier<Credential>: Handleable] = [:]
    private var addSupplementalInformationHandler: [Identifier<Credential>: Handleable] = [:]
    private var cancelSupplementInformationHandler: [Identifier<Credential>: Handleable] = [:]
    private var fetchCredentialsHandler: Handleable?
    
    private init() {
        service = TinkLink.shared.client.credentialService
        market = TinkLink.shared.client.market
        locale = TinkLink.shared.client.locale
        authenticationManager = AuthenticationManager.shared
    }
    
    func addCredential(for provider: Provider, fields: [String: String], completion: @escaping(Result<Credential, Error>) -> Void) -> Handleable {
        var multiHandler = MultiHandler()
        let market = Market(code: provider.marketCode)
        let authHandler = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self] _ in
            guard let self = self, self.createCredentialHandler[provider.name] == nil else { return }
            let handler = self.service.createCredential(providerName: provider.name, fields: fields, completion: { (result) in
                DispatchQueue.main.async {
                    do {
                        let credential = try result.get()
                        completion(.success(credential))
                        self.credentials[credential.id] = credential
                    } catch let error {
                        completion(.failure(error))
                    }
                    self.createCredentialHandler[provider.name] = nil
                }
            })
            self.createCredentialHandler[provider.name] = handler
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
        addSupplementalInformationHandler[credential.id] = self.service.supplementInformation(credentialID: credential.id, fields: supplementalInformationFields) { [weak self] result in
            DispatchQueue.main.async {
                self?.addSupplementalInformationHandler[credential.id] = nil
                completion(result)
            }
        }
    }
    
    /// - Precondition: Service should be configured with access token before this method is called.
    func cancelSupplementInformation(for credential: Credential, completion: @escaping (Result<Void, Error>) -> Void) {
        precondition(service.metadata.hasAuthorization, "Service doesn't have authentication metadata set!")
        cancelSupplementInformationHandler[credential.id] = self.service.cancelSupplementInformation(credentialID: credential.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.cancelSupplementInformationHandler[credential.id] = nil
                completion(result)
            }
        }
    }

    func performFetchIfNeeded() {
        if fetchCredentialsHandler == nil {
            performFetch()
        }
    }

    func performFetch() {
        fetchCredentialsHandler = service.credentials { [weak self] result in
            DispatchQueue.main.async {
                self?.fetchCredentialsHandler = nil
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
    
    // TODO: Create polling handler for handle all the pollings
    func pollingStatus(for credential: Credential) {
        guard credentialStatusPollingHandler[credential.id] == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.credentialStatusPollingHandler[credential.id] = self.service.credentials { [weak self, credential] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.credentialStatusPollingHandler[credential.id] = nil
                    do {
                        let credentials = try result.get()
                        if let updatedCredential = credentials.first(where: { $0.id == credential.id}) {
                            if updatedCredential.status == .updating {
                                self.credentials[credential.id] = updatedCredential
                                self.pollingStatus(for: updatedCredential)
                            } else if updatedCredential.status == .awaitingSupplementalInformation {
                                self.credentials[credential.id] = updatedCredential
                            } else if updatedCredential.status == credential.status {
                                self.pollingStatus(for: updatedCredential)
                            } else {
                                self.credentials[credential.id] = updatedCredential
                            }
                        } else {
                            fatalError("No such credential with " + credential.id.rawValue)
                        }
                    } catch {
                        NotificationCenter.default.post(name: .credentialStoreErrorOccured, object: self, userInfo: [CredentialStoreErrorOccuredNotificationErrorKey: error])
                    }
                }
            }
        })
    }

}

extension Notification.Name {
    static let credentialStoreChanged = Notification.Name("TinkLinkCredentialStoreChangedNotificationName")
    static let credentialStoreErrorOccured = Notification.Name("TinkLinkCredentialStoreErrorOccuredNotificationName")
}

/// User info key for credentialStoreErrorOccured notification.
let CredentialStoreErrorOccuredNotificationErrorKey = "error"
