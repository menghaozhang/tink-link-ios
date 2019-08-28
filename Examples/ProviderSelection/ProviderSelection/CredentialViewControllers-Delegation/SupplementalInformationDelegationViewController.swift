import UIKit

/**
 Example of how to use the credential field supplementa information to update credential
 */
protocol SupplementalInformationDelegationViewControllerDelegate: AnyObject {
    func supplementInformationViewController(_ viewController: SupplementalInformationDelegationViewController, didSupplementCredential credential: Credential)
}

final class SupplementalInformationDelegationViewController: UITableViewController {
    
    var credentialContext: CredentialContext?
    var credential: Credential
    
    weak var delegate: SupplementalInformationDelegationViewControllerDelegate?
    
    init(credential: Credential) {
        self.credential = credential
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credential.supplementalInformationFields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        let field = credential.supplementalInformationFields[indexPath.item]
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
        switch credential.supplementalInformationFields.createCredentialValues() {
        case .failure(let fieldSpecificationsError):
            print(fieldSpecificationsError.errors)
        case .success(let fieldValues):
            credentialContext?.supplementInformation(credentialID: credential.id, fields: fieldValues, completion: { [weak self] credential in
                self?.delegate?.supplementInformationViewController(self!, didSupplementCredential: credential)
            })

        }
    }
}

extension SupplementalInformationDelegationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        let textField = cell.textField
        if let indexPath = tableView.indexPath(for: cell) {
            credential.supplementalInformationFields[indexPath.item].value = text
            let field = credential.supplementalInformationFields[indexPath.item]
            let result = field.validatedValue()
            switch result {
            case .failure:
                textField.textColor = .red
            case .success:
                textField.textColor = .green
            }
        }
    }
}
