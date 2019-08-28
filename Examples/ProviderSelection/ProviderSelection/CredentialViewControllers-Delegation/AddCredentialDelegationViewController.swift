import UIKit

/**
 Example of how to use the provider field specification to add credential
 */
final class AddCredentialDelegationViewController: UITableViewController {
    var credentialContext: CredentialContext?
    var provider: Provider
    var credential: Credential?
    
    init(provider: Provider) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        credentialContext = CredentialContext(client: TinkLink.shared.client)
        credentialContext?.delegate = self
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        let field = provider.fields[indexPath.item]
        if let textFieldCell = cell as? TextFieldCell {
            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.fieldDescription
            textFieldCell.textField.isSecureTextEntry = field.isMasked
            textFieldCell.textField.isEnabled = !field.isImmutable
            textFieldCell.textField.text = field.value
        }
        return cell
    }
    
    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        switch provider.fields.createCredentialValues() {
        case .failure(let fieldSpecificationsError):
            print(fieldSpecificationsError.errors)
        case .success(let fieldValues):
            credentialContext?.createCredential(for: provider, fields: fieldValues)
        }
    }
    
    private func showSupplementalInformation(for credential: Credential) {
        let supplementalInformationDelegationViewController = SupplementalInformationDelegationViewController(credential: credential)
        show(supplementalInformationDelegationViewController, sender: self)
    }
    
    private func showCredentialUpdated(for credential: Credential) {
        let finishedCredentialUpdatedViewController = FinishedCredentialUpdatedViewController(credential: credential)
        show(finishedCredentialUpdatedViewController, sender: self)
    }
}

extension AddCredentialDelegationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textField = cell.textField
        if let value = (textField.text as NSString?)?.replacingCharacters(in: range, with: string), let indexPath = tableView.indexPath(for: cell) {
            provider.fields[indexPath.item].value = value
            let result = provider.fields[indexPath.item].validatedValue()
            switch result {
            case .failure:
                textField.textColor = .red
            case .success:
                textField.textColor = .green
            }
        }
        return true
    }
}

extension AddCredentialDelegationViewController: SupplementalInformationDelegationViewControllerDelegate {
    func supplementInformationViewController(_ viewController: SupplementalInformationDelegationViewController, didSupplementCredential credential: Credential) {
        navigationController?.popToViewController(self, animated: false)
        // Maybe show loading
    }
}

extension AddCredentialDelegationViewController: CredentialContextDelegate {
    func credentialContext(_ context: CredentialContext, didChangeStatusForCredential credential: Credential) {
//        navigationController?.popToViewController(self, animated: false)
    }
    
    func credentialContext(_ context: CredentialContext, awaitingSupplementalInformation credential: Credential) {
        self.credential = credential
        showSupplementalInformation(for: credential)
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
