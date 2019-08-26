import UIKit

/**
 Example of how to use the provider field specification to add credential
 */
final class AddCredentialViewController: UITableViewController {
    var credentialContext: CredentialContextWithCallBack?
    var provider: Provider?
    var supplementalInformation: SupplementalInformationContext?
    // TODO: find a better way to check the input field
    var textFields: [UITextField] = []
    var credential: Credential?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = Client(clientId: "123")
        credentialContext = CredentialContextWithCallBack(client: client)
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let supplementalInformationViewController = segue.destination as? SupplementalInformationViewController {
            supplementalInformationViewController.supplementalInformation = supplementalInformation
            supplementalInformationViewController.delegate = self
        } else if let finishedCredentialUpdatedViewController = segue.destination as? FinishedCredentialUpdatedViewController {
            finishedCredentialUpdatedViewController.credential = credential
        }
    }
    
    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        textFields.forEach { $0.resignFirstResponder() }
        switch provider!.fields.createCredentialValues() {
        case .failure(let error):
            print(error)
        case .success(let fieldValues):
            credentialContext?.addCredential(for: provider!, fields: fieldValues, progressHandler: { status in
                switch status {
                case .authenticating, .created:
                    break
                case .awaitingSupplementalInformation(let supplementalInformation):
                    self.showSupplementalInformation(for: supplementalInformation)
                case .awaitingThirdPartyAppAuthentication(let thirdPartyURL):
                    UIApplication.shared.open(thirdPartyURL, options: [:], completionHandler: { success in
                        if !success {
                            // Open download page
                        }
                    })
                case .updating(let status):
                    break
                }
            }, completion: { result in
                switch result {
                case .failure:
                    // Show error
                    break
                case .success(let credential):
                    self.showCredentialUpdated(for: credential)
                }
            })
        }
    }
    
    private func showSupplementalInformation(for supplementalInformation: SupplementalInformationContext) {
        self.supplementalInformation = supplementalInformation
        performSegue(withIdentifier: "AddSupplementalInformation", sender: self)
    }
    
    private func showCredentialUpdated(for credential: Credential) {
        performSegue(withIdentifier: "CredentialUpdated", sender: self)
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

extension AddCredentialViewController: SupplementalInformationViewControllerDelegate {
    func supplementInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementCredential credential: SupplementalInformationContext) {
        navigationController?.popToViewController(self, animated: false)
        // Maybe show loading
    }
}

extension AddCredentialViewController: CredentialContextDelegate {
    func credentialContext(_ context: CredentialContext, didChangeStatusForCredential credential: Credential) {
//        navigationController?.popToViewController(self, animated: false)
    }
    
    func credentialContext(_ context: CredentialContext, awaitingSupplementalInformation credential: Credential) {
        self.credential = credential
//        showSupplementalInformation(for: credential)
    }
    
    func credentialContext(_ context: CredentialContext, awaitingThirdPartyAppAuthentication credential: Credential) {
        //        UIApplication.shared.open(credential, options: <#T##[UIApplication.OpenExternalURLOptionsKey : Any]#>, completionHandler: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
    }
    
    func credentialContext(_ context: CredentialContext, didStartUpdatingCredential credential: Credential) {
        // Backend updating, multiple call expected, update accordingly
    }
    
    func credentialContext(_ context: CredentialContext, didFinishUpdatingCredential credential: Credential) {
        showCredentialUpdated(for: credential)
    }
    
    func credentialContext(_ context: CredentialContext, didReceiveErrorForCredential credential: Credential) {
        present(UIAlertController(title: "credential error", message: "", preferredStyle: .alert), animated: true)
    }
}
