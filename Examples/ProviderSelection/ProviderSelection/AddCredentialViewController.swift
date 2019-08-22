import UIKit

struct Credential {
    var id: String
    var type: `Type`
    var status: Status
    var providerName: String
    var sessionExpiryDate: Date?
    var supplementalInformationFields: [Provider.FieldSpecification] = []
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let credential = Credential(id: provider.name + provider.accessType.rawValue, type: .mobileBankID, status: .created, providerName: provider.name, sessionExpiryDate: nil, supplementalInformationFields: [])
            self.credentials[credential.id] = credential
            self.observe(credential: credential)
        }
    }
    
    private func observe(credential: Credential) {
        // Observed updates from streaming
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [credential] in
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

final class AddCredentialViewController: UITableViewController, UITextFieldDelegate {
    var credentialContext: CredentialContext?
    var provider: Provider?
    var credentialFields: CredentialFields?
    // TODO: find a better way to check the input field
    var textFields: [UITextField] = []
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        textFields.forEach { $0.resignFirstResponder() }
        guard let credentialFields = credentialFields else {
            return
        }
        switch credentialFields.fieldValuesForCreateCredential {
        case .failure(let error):
            print(error)
        case .success(let fieldValues):
            credentialContext?.createCredential(for: provider!, fields: fieldValues)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = Client(clientId: "123")
        credentialContext = CredentialContext(client: client)
        credentialContext?.delegate = self
        
        credentialFields = CredentialFields(provider: provider!)
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialFields!.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell, let field = credentialFields?.fields[indexPath.item] {
            textFields.append(textFieldCell.textField)
            textFieldCell.textField.delegate = self
            textFieldCell.textField.placeholder = field.fieldDescription
            textFieldCell.textField.isSecureTextEntry = field.isMasked
            textFieldCell.textField.isEnabled = !field.isImmutable
            textFieldCell.textField.text = field.value
        }
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let index = textFields.firstIndex(of: textField), let credentialFields = credentialFields {
            let field = credentialFields.fields[index]
            let result = credentialFields.update(for: field, value: textField.text ?? "")
            switch result {
            case .failure:
                textField.textColor = .red
            case .success:
                textField.textColor = .green
            }
        }
    }
}

extension AddCredentialViewController: CredentialContextDelegate {
    func credentialContext(_ context: CredentialContext, awaitingSupplementalInformation credential: Credential) {
        print(#function)
    }
    
    func credentialContext(_ context: CredentialContext, awaitingMobileBankIDAuthentication credential: Credential) {
        print(#function)
    }
    
    func credentialContext(_ context: CredentialContext, awaitingThirdPartyAppAuthentication credential: Credential) {
        print(#function)
    }
    
    func credentialContext(_ context: CredentialContext, didStartUpdatingCredential credential: Credential) {
        print(#function)
    }
    
    func credentialContext(_ context: CredentialContext, didChangeStatusForCredential credential: Credential) {
        print(#function)
    }
    
    func credentialContext(_ context: CredentialContext, didFinishUpdatingCredential credential: Credential) {
        print(#function)
    }
    
    func credentialContext(_ context: CredentialContext, didReceiveErrorForCredential credential: Credential) {
        print(#function)
    }
}
