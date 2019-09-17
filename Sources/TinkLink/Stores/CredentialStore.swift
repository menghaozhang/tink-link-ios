import Foundation

final class CredentialStore {
    static let shared = CredentialStore()
    
    var credentials: [Identifier<Credential>: Credential] = [:] {
        didSet {
            NotificationCenter.default.post(name: .credentialStoreChanged, object: self)
        }
    }
    private let authenticationManager: AuthenticationManager
    private var service: CredentialService
    private var createCredentialCanceller: [Identifier<Provider>: Cancellable] = [:]
    private var credentialStatusPollingCanceller: [Identifier<Credential>: Cancellable] = [:]
    private var addSupplementalInformationCanceller: [Identifier<Credential>: Cancellable] = [:]
    private var cancelSupplementInformationCanceller: [Identifier<Credential>: Cancellable] = [:]
    
    private init() {
        service = TinkLink.shared.client.credentialService
        authenticationManager = AuthenticationManager.shared
    }
    
    func addCredential(for provider: Provider, fields: [String: String], completion: @escaping(Result<Credential, Error>) -> Void) {
        authenticationManager.authenticateIfNeeded(service: service) { [weak self] _ in
            guard let self = self, self.createCredentialCanceller[provider.name] == nil else { return }
            let canceller = self.service.createCredential(providerName: provider.name, fields: fields, completion: { (result) in
                DispatchQueue.main.async {
                    do {
                        let credential = try result.get()
                        completion(.success(credential))
                        self.credentials[credential.id] = credential
                        self.pollingStatus(for: credential)
                    } catch let error {
                        completion(.failure(error))
                    }
                    self.createCredentialCanceller[provider.name] = nil
                }
            })
            self.createCredentialCanceller[provider.name] = canceller
        }
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [String: String]) {
        authenticationManager.authenticateIfNeeded(service: service) { [weak self] _ in
            guard let self = self else { return }
            self.addSupplementalInformationCanceller[credential.id] = self.service.supplementInformation(credentialID: credential.id, fields: supplementalInformationFields) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        // error
                        break
                    case .success:
                        // polling
                        self.pollingStatus(for: credential)
                    }
                }
                self.addSupplementalInformationCanceller[credential.id] = nil
            }
        }
    }
    
    func cancelSupplementInformation(for credential: Credential) {
        authenticationManager.authenticateIfNeeded(service: service) { [weak self] _ in
            guard let self = self, self.cancelSupplementInformationCanceller[credential.id] == nil else { return }
            self.cancelSupplementInformationCanceller[credential.id] = self.service.cancelSupplementInformation(credentialID: credential.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        break
                    case .success(let credential):
                        // polling
                        break
                    }
                    self.cancelSupplementInformationCanceller[credential.id] = nil
                }
            }
        }
    }
    
    // TODO: Create polling handler for handle all the pollings
    private func pollingStatus(for credential: Credential) {
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
                    } catch let error {
                        print(error)
                    }
                }
            }
        })
    }
}

extension Notification.Name {
    static let credentialStoreChanged = Notification.Name("TinkLinkCredentialStoreChangedNotificationName")
}
