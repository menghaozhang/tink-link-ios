import Foundation

public class CredentialContext {

    public private(set) var credentials: [Identifier<Credential>: Credential] = [:]
    private let credentialStore = CredentialStore.shared
    private let storeObserverToken = StoreObserverToken()
    
    private var progressHandlers: [Identifier<Credential>: (AddCredentialTask.Status) -> Void] = [:]
    private var completions: [Identifier<Credential>: (Result<Credential, Error>) -> Void] = [:]
    
    public init() {
        credentials = credentialStore.credentials
        credentialStore.addCredentialsObserver(token: storeObserverToken) { [weak self] tokenId in
            guard let strongSelf = self, strongSelf.storeObserverToken.has(id: tokenId) else {
                return
            }
            strongSelf.credentials.forEach({ (key, value) in
                if let credential = strongSelf.credentialStore.credentials[key] {
                    // TODO: Make credential equatable
                    if value.status != credential.status {
                        strongSelf.handleUpdate(for: credential)
                    } else if value.status == .updating || value.status == .awaitingSupplementalInformation {
                        strongSelf.handleUpdate(for: credential)
                    }
                }
            })
            strongSelf.credentials = strongSelf.credentialStore.credentials
        }
    }
    
    public func addCredential(for provider: Provider, fields: [Provider.FieldSpecification], progressHandler: @escaping (AddCredentialTask.Status) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) -> AddCredentialTask {
        let task = AddCredentialTask()
        task.callCanceller = credentialStore.addCredential(for: provider, fields: fields) { [weak self] result in
            guard let self = self else { return }
            do {
                let credential = try result.get()
                self.progressHandlers[credential.id] = progressHandler
                self.completions[credential.id] = completion
            } catch {
                completion(.failure(error))
            }
        }
        return task
    }
    
    private func handleUpdate(for credential: Credential) {
        guard let progressHandler = progressHandlers[credential.id], let completion = completions[credential.id] else { return }
        switch credential.status {
        case .created:
            progressHandler(.created)
        case .authenticating:
            progressHandler(.authenticating)
        case .awaitingSupplementalInformation:
            let supplementInformationTask = SupplementInformationTask(credentialContext: self, credential: credential)
            progressHandler(.awaitingSupplementalInformation(supplementInformationTask))
        case .awaitingThirdPartyAppAuthentication, .awaitingMobileBankIDAuthentication:
            guard let url = credential.thirdPartyAppAuthentication?.deepLinkURL else {
                assertionFailure("Missing third pary app authentication deeplink URL!")
                return
            }
            progressHandler(.awaitingThirdPartyAppAuthentication(url))
        case .updating:
            progressHandler(.updating(status: credential.statusPayload))
        case .updated:
            completion(.success(credential))
        case .permanentError:
            completion(.failure(AddCredentialTask.Error.permanentFailure))
        case .temporaryError:
            completion(.failure(AddCredentialTask.Error.temporaryFailure))
        case .authenticationError:
            completion(.failure(AddCredentialTask.Error.authenticationFailed))
        case .disabled:
            fatalError("Credential shouldn't be disabled during creation.")
        case .sessionExpired:
            fatalError("Credential's session shouldn't expire during creation.")
        case .unknown:
            assertionFailure("Unknown credential status!")
        }
    }
    
    func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [Provider.FieldSpecification]) {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: supplementalInformationFields)
    }
    
    func cancelSupplementInformation(for credential: Credential) {
        credentialStore.cancelSupplementInformation(for: credential)
    }
}
