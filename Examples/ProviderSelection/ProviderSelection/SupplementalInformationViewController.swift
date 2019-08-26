import UIKit

/**
 Example of how to use the credential field supplementa information to update credential
 */
protocol SupplementalInformationViewControllerDelegate: AnyObject {
    func supplementInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementCredential credential: SupplementalInformationContext)
}

final class SupplementalInformationViewController: UITableViewController {
    
    var supplementalInformation: SupplementalInformationContext?
    
    weak var delegate: SupplementalInformationViewControllerDelegate?
    
    var textFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supplementalInformation!.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell, let field = supplementalInformation?.fields[indexPath.item] {
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
        switch supplementalInformation!.fields.createCredentialValues() {
        case .failure(let error):
            print(error)
        case .success:
            supplementalInformation?.submitUpdate()
            self.delegate?.supplementInformationViewController(self, didSupplementCredential: supplementalInformation!)
        }
    }
}

extension SupplementalInformationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, DidBeginEditing textField: UITextField) {
    }
    
    func textFieldCell(_ cell: TextFieldCell, DidEndEditing textField: UITextField) {
        if let indexPath = tableView.indexPath(for: cell) {
            supplementalInformation!.fields[indexPath.item].value = textField.text ?? ""
            let field = supplementalInformation!.fields[indexPath.item]
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
