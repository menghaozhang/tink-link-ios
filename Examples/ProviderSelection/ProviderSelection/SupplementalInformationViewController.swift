import UIKit

final class SupplementalInformationViewController: UITableViewController {
    
    var credentialContext: CredentialContext?
    var credential: Credential?
    
    var textFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credential!.supplementalInformationFields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell, let field = credential?.supplementalInformationFields[indexPath.item] {
            textFields.append(textFieldCell.textField)
            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.fieldDescription
            textFieldCell.textField.isSecureTextEntry = field.isMasked
            textFieldCell.textField.isEnabled = !field.isImmutable
            textFieldCell.textField.text = field.value
        }
        return cell
    }
    
    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        textFields.forEach { $0.resignFirstResponder() }
        switch credential!.supplementalInformationFields.createCredentialValues() {
        case .failure(let error):
            print(error)
        case .success(let fieldValues):
            credentialContext?.supplementInformation(credentialID: credential!.id, fields: fieldValues)
        }
    }
}

extension SupplementalInformationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, DidBeginEditing textField: UITextField) {
    }
    
    func textFieldCell(_ cell: TextFieldCell, DidEndEditing textField: UITextField) {
        if let indexPath = tableView.indexPath(for: cell) {
            credential!.supplementalInformationFields[indexPath.item].value = textField.text ?? ""
            let field = credential!.supplementalInformationFields[indexPath.item]
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
