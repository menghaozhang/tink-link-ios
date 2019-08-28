import UIKit

/**
 Example of how to use the credential field supplementa information to update credential
 */
protocol SupplementalInformationViewControllerDelegate: AnyObject {
    func supplementInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential)
}

final class SupplementalInformationViewController: UITableViewController {
    
    let supplementalInformationTask: SupplementalInformationTask
    
    weak var delegate: SupplementalInformationViewControllerDelegate?
    
    init(supplementalInformationTask: SupplementalInformationTask) {
        self.supplementalInformationTask = supplementalInformationTask
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle
extension SupplementalInformationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        
        navigationItem.title = "Enter Supplemental Information"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
    }
}

// MARK: - UITableViewDataSource
extension SupplementalInformationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supplementalInformationTask.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell {
            let field = supplementalInformationTask.fields[indexPath.item]
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
extension SupplementalInformationViewController {
    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        tableView.resignFirstResponder()
        switch supplementalInformationTask.fields.createCredentialValues() {
        case .failure(let fieldSpecificationsError):
            print(fieldSpecificationsError.errors)
        case .success:
            supplementalInformationTask.submitUpdate()
            self.delegate?.supplementInformationViewController(self, didSupplementInformationForCredential: supplementalInformationTask.credential)
        }
    }
}

// MARK: - TextFieldCellDelegate
extension SupplementalInformationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textField = cell.textField
        if let value = (textField.text as NSString?)?.replacingCharacters(in: range, with: string), let indexPath = tableView.indexPath(for: cell) {
            supplementalInformationTask.fields[indexPath.item].value = value
            let field = supplementalInformationTask.fields[indexPath.item]
            let result = field.validatedValue()
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
