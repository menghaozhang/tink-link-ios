import UIKit
import TinkLink

/**
 Example of how to use the credential field supplementa information to update credential
 */
protocol SupplementalInformationViewControllerDelegate: AnyObject {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController)
    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential)
}

final class SupplementalInformationViewController: UITableViewController {
    
    let supplementInformationTask: SupplementInformationTask
    
    weak var delegate: SupplementalInformationViewControllerDelegate?
    
    init(supplementInformationTask: SupplementInformationTask) {
        self.supplementInformationTask = supplementInformationTask
        super.init(style: .grouped)
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

// MARK: - UITableViewDataSource
extension SupplementalInformationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supplementInformationTask.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell {
            let field = supplementInformationTask.fields[indexPath.item]
            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.fieldDescription
            textFieldCell.textField.isSecureTextEntry = field.isMasked
            textFieldCell.textField.isEnabled = !field.isImmutable || field.value.isEmpty
            textFieldCell.textField.text = field.value
        }
        return cell
    }
}

// MARK: - Actions
extension SupplementalInformationViewController {
    @objc private func cancelButtonPressed(_ sender: UIBarButtonItem) {
        supplementInformationTask.cancel()
        delegate?.supplementalInformationViewControllerDidCancel(self)
    }

    @objc private func doneButtonPressed(_ sender: UIBarButtonItem) {
        tableView.resignFirstResponder()
        do {
            try supplementInformationTask.fields.validateValues()
            supplementInformationTask.submit()
            self.delegate?.supplementalInformationViewController(self, didSupplementInformationForCredential: supplementInformationTask.credential)
        } catch let fieldSpecificationsError as FieldSpecificationsError {
            print(fieldSpecificationsError.errors)
        } catch {
            print(error)
        }
    }
}

// MARK: - TextFieldCellDelegate
extension SupplementalInformationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        let textField = cell.textField
        if let indexPath = tableView.indexPath(for: cell) {
            supplementInformationTask.fields[indexPath.item].value = text
            let field = supplementInformationTask.fields[indexPath.item]
            navigationItem.rightBarButtonItem?.isEnabled = field.isValueValid
        }
    }
}
