import Foundation
import SwiftGRPC

final class CredentialStore {
    static let shared = CredentialStore()
    
    private(set) var credentials: [Identifier<Credential>: Credential] = [:] {
        didSet {
            NotificationCenter.default.post(name: .credentialStoreChanged, object: self)
        }
    }
    private let authenticationManager: AuthenticationManager
    private let market: Market
    private let locale: Locale
    private var service: CredentialService
    private var createCredentialCanceller: [Identifier<Provider>: Cancellable] = [:]
    private var credentialStatusPollingCanceller: [Identifier<Credential>: Cancellable] = [:]
    private var addSupplementalInformationCanceller: [Identifier<Credential>: Cancellable] = [:]
    private var cancelSupplementInformationCanceller: [Identifier<Credential>: Cancellable] = [:]
    private var fetchCredentialsCanceller: Cancellable?
    
    private init() {
        service = TinkLink.shared.client.credentialService
        market = TinkLink.shared.client.market
        locale = TinkLink.shared.client.locale
        authenticationManager = AuthenticationManager.shared
    }
    
    func addCredential(for provider: Provider, fields: [String: String], completion: @escaping(Result<Credential, Error>) -> Void) -> Cancellable {
        var multiCanceller = MultiCanceller()
        let market = Market(code: provider.marketCode)
        let authCanceller = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self] _ in
            guard let self = self, self.createCredentialCanceller[provider.name] == nil else { return }
            let canceller = self.service.createCredential(providerName: provider.name, fields: fields, completion: { (result) in
                DispatchQueue.main.async {
                    do {
                        let credential = try result.get()
                        completion(.success(credential))
                        self.credentials[credential.id] = credential
                    } catch let error {
                        completion(.failure(error))
                    }
                    self.createCredentialCanceller[provider.name] = nil
                }
            })
            self.createCredentialCanceller[provider.name] = canceller
            multiCanceller.add(canceller)
        }
        if let canceller = authCanceller {
            multiCanceller.add(canceller)
        }
        return multiCanceller
    }
    
    /// - Precondition: Service should be configured with access token before this method is called.
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) {
        precondition(service.metadata.hasAuthorization, "Service doesn't have authentication metadata set!")
        addSupplementalInformationCanceller[credential.id] = self.service.supplementInformation(credentialID: credential.id, fields: supplementalInformationFields) { [weak self] result in
            DispatchQueue.main.async {
                self?.addSupplementalInformationCanceller[credential.id] = nil
                completion(result)
            }
        }
    }
    
    /// - Precondition: Service should be configured with access token before this method is called.
    func cancelSupplementInformation(for credential: Credential, completion: @escaping (Result<Void, Error>) -> Void) {
        precondition(service.metadata.hasAuthorization, "Service doesn't have authentication metadata set!")
        cancelSupplementInformationCanceller[credential.id] = self.service.cancelSupplementInformation(credentialID: credential.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.cancelSupplementInformationCanceller[credential.id] = nil
                completion(result)
            }
        }
    }

    func performFetch() {
        fetchCredentialsCanceller = service.credentials { [weak self] result in
            do {
                let credentials = try result.get()
                self?.credentials = Dictionary(grouping: credentials, by: { $0.id })
                    .compactMapValues { $0.first }
            } catch {
                NotificationCenter.default.post(name: .credentialStoreErrorOccured, object: self, userInfo: [CredentialStoreErrorOccuredNotificationErrorKey: error])
            }
        }
    }
    
    // TODO: Create polling handler for handle all the pollings
    func pollingStatus(for credential: Credential) {
        guard credentialStatusPollingCanceller[credential.id] == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.credentialStatusPollingCanceller[credential.id] = self.service.credentials { [weak self, credential] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.credentialStatusPollingCanceller[credential.id] = nil
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
