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
    
    private var form: Form
    private var didFirstFieldBecomeFirstResponder = false

    init(supplementInformationTask: SupplementInformationTask) {
        self.supplementInformationTask = supplementInformationTask
        self.form = Form(credential: supplementInformationTask.credential)
        
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
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didFirstFieldBecomeFirstResponder, !form.fields.isEmpty, let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell {
            cell.textField.becomeFirstResponder()
            didFirstFieldBecomeFirstResponder = true
        }
    }
}

// MARK: - UITableViewDataSource
extension SupplementalInformationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        if let textFieldCell = cell as? TextFieldCell {
            let field = form.fields[indexPath.item]
            
            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.attributes.placeholder
            textFieldCell.textField.isSecureTextEntry = field.attributes.isSecureTextEntry
            textFieldCell.textField.isEnabled = field.attributes.isEnabled
            textFieldCell.textField.text = field.text
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
            try form.validateValues()
            supplementInformationTask.submit(form: form)
            self.delegate?.supplementalInformationViewController(self, didSupplementInformationForCredential: supplementInformationTask.credential)
        } catch let fieldSpecificationsError as Form.FieldsError {
            print(fieldSpecificationsError.errors)
        } catch {
            print(error)
        }
    }
}

// MARK: - TextFieldCellDelegate
extension SupplementalInformationViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            form.fields[indexPath.item].text = text
            navigationItem.rightBarButtonItem?.isEnabled = form.fields[indexPath.item].isValueValid
        }
    }
}
