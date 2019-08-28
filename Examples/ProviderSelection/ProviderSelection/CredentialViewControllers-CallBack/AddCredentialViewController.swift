import UIKit

/**
 Example of how to use the provider field specification to add credential
 */
final class AddCredentialViewController: UITableViewController {
    var credentialContext: CredentialContextWithCallBack?
    var provider: Provider
    
    init(provider: Provider) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle
extension AddCredentialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = Client(clientId: "123")
        credentialContext = CredentialContextWithCallBack(client: client)
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false
        
        navigationItem.title = "Enter your credentials"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
    }
}

// MARK: - UITableViewDataSource
extension AddCredentialViewController {
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
}

// MARK: - Actions
extension AddCredentialViewController {
    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        switch provider.fields.createCredentialValues() {
        case .failure(let fieldSpecificationsError):
            print(fieldSpecificationsError.errors)
        case .success(let fieldValues):
            credentialContext?.addCredential(for: provider, fields: fieldValues, progressHandler: { status in
                switch status {
                case .authenticating, .created:
                    break
                case .awaitingSupplementalInformation(let supplementInformationTask):
                    self.showSupplementalInformation(for: supplementInformationTask)
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
}

// MARK: - Navigation
extension AddCredentialViewController {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: self)
    }
    
    private func showCredentialUpdated(for credential: Credential) {
        let finishedCredentialUpdatedViewController = FinishedCredentialUpdatedViewController(credential: credential)
        show(finishedCredentialUpdatedViewController, sender: self)
    }
}

// MARK: - TextFieldCellDelegate
extension AddCredentialViewController: TextFieldCellDelegate {
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

// MARK: - SupplementalInformationViewControllerDelegate
extension AddCredentialViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential) {
        dismiss(animated: true)
        // Maybe show loading
    }
}
