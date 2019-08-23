import Foundation
// Mocked Credential context
protocol CredentialContextDelegate: AnyObject {
    func credentialContext(_ context: CredentialContext, awaitingSupplementalInformation credential: Credential)
    func credentialContext(_ context: CredentialContext, awaitingThirdPartyAppAuthentication credential: Credential)
    func credentialContext(_ context: CredentialContext, didStartUpdatingCredential credential: Credential)
    func credentialContext(_ context: CredentialContext, didChangeStatusForCredential credential: Credential)
    func credentialContext(_ context: CredentialContext, didFinishUpdatingCredential credential: Credential)
    func credentialContext(_ context: CredentialContext, didReceiveErrorForCredential credential: Credential)
}

class CredentialContext {
    var client: Client
    weak var delegate: CredentialContextDelegate?
    
    init(client: Client) {
        self.client = client
    }
    
    private var credentials: [String: Credential] = [:]
    
    func createCredential(for provider: Provider, fields: [String: String]) {
        
        // Received async request response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [provider] in
            let credential = Credential(id: provider.name + provider.accessType.rawValue, type: provider.credentialType, status: .created, providerName: provider.name, sessionExpiryDate: nil, supplementalInformationFields: [], fields: [:])
            self.credentials[credential.id] = credential
            self.observe(credential: credential)
        }
    }
    
    func supplementInformation(credentialID: String, fields: [String: String], completion: @escaping(Credential) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let credential = self.credentials[credentialID] {
                self.update(credential: credential, to: .updated)
            }
        }
    }
    
    private func observe(credential: Credential) {
        // Observed updates from streaming
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [credential] in
            var multableCredential = credential
            multableCredential.status = .awaitingSupplementalInformation
            multableCredential.supplementalInformationFields = [Provider.securityCodeFieldSpecification, Provider.inputCodeFieldSpecification]
            self.credentials[multableCredential.id] = multableCredential
            self.handle(credential: multableCredential)
        }
    }
    
    private func handle(credential: Credential) {
        // New status update
        delegate?.credentialContext(self, didChangeStatusForCredential: credential)
        // Authenticating states
        switch credential.status {
        case .created, .authenticating:
            break
        // Authentications
        case .awaitingSupplementalInformation:
            delegate?.credentialContext(self, awaitingSupplementalInformation: credential)
        case .awaitingMobileBankIDAuthentication, .awaitingThirdPartyAppAuthentication:
            delegate?.credentialContext(self, awaitingThirdPartyAppAuthentication: credential)
        // Updating states
        case .updating:
            delegate?.credentialContext(self, didStartUpdatingCredential: credential)
        case .updated:
            delegate?.credentialContext(self, didFinishUpdatingCredential: credential)
        // Error states
        case .permanentError, .temporaryError, .authenticationError, .sessionExpired:
            delegate?.credentialContext(self, didReceiveErrorForCredential: credential)
        // Unhandled states
        case .unknown, .disabled:
            break
        }
    }
    
    subscript(_ id: String) -> Credential? {
        return credentials[id]
    }
}

// Helper only for internal example
extension CredentialContext {
    func update(credential: Credential, to status: Credential.Status) {
        var multableCredential = self.credentials[credential.id]
        multableCredential?.status = status
        if let credential = multableCredential {
            handle(credential: credential)
        }
    }
}
