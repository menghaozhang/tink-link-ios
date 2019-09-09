import Foundation

public class CredentialContext {
    public enum AddCredentialStatus {
        case created
        case authenticating
        case updating(status: String)
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(URL)
    }

    enum AddCredentialError: Error {
        case authenticationFailed
        case temporaryFailure
        case permanentFailure
    }
    
    public private(set) var credentials: [Identifier<Credential>: Credential] = [:]
    private let credentialStore = CredentialStore.shared
    private let storeObserverToken = StoreObserverToken()
    
    private var progressHandlers: [Identifier<Credential>: (AddCredentialStatus) -> Void] = [:]
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
    
    public func addCredential(for provider: Provider, fields: [Provider.FieldSpecification], progressHandler: @escaping (AddCredentialStatus) -> Void,  completion: @escaping(Result<Credential, Error>) -> Void) {
        credentialStore.addCredential(for: provider, fields: fields) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let credential):
                strongSelf.progressHandlers[credential.id] = progressHandler
                strongSelf.completions[credential.id] = completion
            }
        }
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
            completion(.failure(AddCredentialError.permanentFailure))
        case .temporaryError:
            completion(.failure(AddCredentialError.temporaryFailure))
        case .authenticationError:
            completion(.failure(AddCredentialError.authenticationFailed))
        case .disabled:
            fatalError("Credential shouldn't be disabled during creation.")
        case .sessionExpired:
            fatalError("Credential's session shouldn't expire during creation.")
        case .unknown:
            assertionFailure("Unknown credential status!")
        }
    }
    
    fileprivate func addSupplementalInformation(for credential: Credential, supplementalInformationFields: [Provider.FieldSpecification]) {
        credentialStore.addSupplementalInformation(for: credential, supplementalInformationFields: supplementalInformationFields)
    }
    
    fileprivate func cancelSupplementInformation(for credential: Credential) {
        credentialStore.cancelSupplementInformation(for: credential)
    }
}
