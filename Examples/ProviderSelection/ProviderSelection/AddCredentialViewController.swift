import UIKit

final class AddCredentialViewController: UITableViewController {
    var credentialContext: CredentialContext?
    var provider: Provider?
    // TODO: find a better way to check the input field
    var textFields: [UITextField] = []
    var credential: Credential?
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        textFields.forEach { $0.resignFirstResponder() }
        switch provider!.fields.createCredentialValues() {
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
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider!.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell, let field = provider?.fields[indexPath.item] {
            textFields.append(textFieldCell.textField)
            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.fieldDescription
            textFieldCell.textField.isSecureTextEntry = field.isMasked
            textFieldCell.textField.isEnabled = !field.isImmutable
            textFieldCell.textField.text = field.value
        }
        return cell
    }
    
    private func showSupplementalInformation(for credential: Credential) {
        performSegue(withIdentifier: "AddSupplementalInformation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let supplementalInformationViewController = segue.destination as? SupplementalInformationViewController {
            supplementalInformationViewController.credential = credential
            supplementalInformationViewController.credentialContext = credentialContext
        }
    }
}

extension AddCredentialViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, DidBeginEditing textField: UITextField) {
    }
    
    func textFieldCell(_ cell: TextFieldCell, DidEndEditing textField: UITextField) {
        if let indexPath = tableView.indexPath(for: cell) {
            provider!.fields[indexPath.item].value = textField.text ?? ""
            let result = provider!.fields[indexPath.item].validatedValue()
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
        self.credential = credential
        showSupplementalInformation(for: credential)
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
