import UIKit

final class SupplementalInformationViewController: UITableViewController, UITextFieldDelegate {
    
    var credentialContext: CredentialContext?
    var credential: Credential?
    var credentialFields: CredentialFields?
    
    var textFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        credentialFields = CredentialFields(credential: credential!)
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
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
