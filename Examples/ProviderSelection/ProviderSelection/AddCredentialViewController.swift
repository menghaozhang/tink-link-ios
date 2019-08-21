import UIKit

struct Credential {
    var id: String
    var type: `Type`
    var status: Status
    var providerName: String
    var sessionExpiryDate: Date?
    
    enum `Type` {
        case unknown
        case password
        case mobileBankID
        case keyfob
        case fraud
        case thirdPartyAuthentication
    }
    
    enum Status {
        case unknown
        case created
        case authenticating
        case updating
        case updated
        case temporaryError
        case authenticationError
        case permanentError
        case awaitingMobileBankIDAuthentication
        case awaitingSupplementalInformation
        case awaitingThirdPartyAppAuthentication
        case disabled
        case sessionExpired
    }
}

protocol CredentialContextDelegate: AnyObject {
    func credentialContext(_ context: CredentialContext, awaitingSupplementalInformation credential: Credential)
    func credentialContext(_ context: CredentialContext, awaitingMobileBankIDAuthentication credential: Credential)
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
        DispatchQueue.main.asyncAfter(deadline: .init(uptimeNanoseconds: 1000)) {
            let credential = Credential(id: provider.name + provider.accessType.rawValue, type: .mobileBankID, status: .created, providerName: provider.name, sessionExpiryDate: nil)
            self.credentials[credential.id] = credential
            self.observe(credential: credential)
        }
    }
    
    private func observe(credential: Credential) {
        // Observed updates from streaming
        DispatchQueue.main.asyncAfter(deadline: .init(uptimeNanoseconds: 2000)) {
            guard let credential = self.credentials["1"] else {
                return
            }
            var multableCredential = credential
            multableCredential.status = .awaitingSupplementalInformation
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
        case .awaitingMobileBankIDAuthentication:
            delegate?.credentialContext(self, awaitingMobileBankIDAuthentication: credential)
        case .awaitingThirdPartyAppAuthentication:
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

final class AddCredentialViewController: UITableViewController {
    var credentialContext: CredentialContext?
    
    var provider: Provider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = Client(clientId: "123")
        credentialContext = CredentialContext(client: client)
        credentialContext?.delegate = self
    }
}

extension AddCredentialViewController: CredentialContextDelegate {
    func credentialContext(_ context: CredentialContext, awaitingSupplementalInformation credential: Credential) {
//        showSupplementalInformation
    }
    
    func credentialContext(_ context: CredentialContext, awaitingMobileBankIDAuthentication credential: Credential) {
//        showMobileBankIDAuthentication
    }
    
    func credentialContext(_ context: CredentialContext, awaitingThirdPartyAppAuthentication credential: Credential) {
//        showThirdPartyAppAuthentication
    }
    
    func credentialContext(_ context: CredentialContext, didStartUpdatingCredential credential: Credential) {
//        loading
    }
    
    func credentialContext(_ context: CredentialContext, didChangeStatusForCredential credential: Credential) {
//        handlingStatusChanges
    }
    
    func credentialContext(_ context: CredentialContext, didFinishUpdatingCredential credential: Credential) {
//        finishLoading
    }
    
    func credentialContext(_ context: CredentialContext, didReceiveErrorForCredential credential: Credential) {
//        errorHandling/retry
    }
}
