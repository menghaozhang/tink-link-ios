import UIKit
import TinkLink

/// Example of how to use the provider field specification to add credential
final class AddCredentialViewController: UITableViewController {
    var credentialContext: CredentialContext?
    let provider: Provider

    private var form: Form
    private var task: AddCredentialTask?
    private var statusViewController: AddCredentialStatusViewController?
    private lazy var doneBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addCredential))
    private var didFirstFieldBecomeFirstResponder = false

    init(provider: Provider) {
        self.provider = provider
        form = Form(provider: provider)
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle
extension AddCredentialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        credentialContext = CredentialContext()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
        tableView.allowsSelection = false
        
        navigationItem.title = "Enter Credentials"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = doneBarButtonItem
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
extension AddCredentialViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        let field = form.fields[indexPath.item]
        if let textFieldCell = cell as? TextFieldCell {
            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.attributes.placeholder
            textFieldCell.textField.isSecureTextEntry = field.attributes.isSecureTextEntry
            textFieldCell.textField.isEnabled = field.attributes.isEnabled
            textFieldCell.textField.text = field.text
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return provider.helpText
    }
}

// MARK: - Actions
extension AddCredentialViewController {
    @objc private func addCredential(_ sender: UIBarButtonItem) {
        view.endEditing(false)

        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        do {
            try form.validateValues()
            task = credentialContext?.addCredential(for: provider, form: form, progressHandler: onUpdate, completion: onCompletion)
        } catch let error as Form.FieldsError {
            // TODO: Handle Error
            print(error.errors)
        } catch {
            // TODO: Handle Error
            print(error)
        }
    }
    
    private func onUpdate(for status: AddCredentialTask.Status) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication):
            if let deepLinkURL = thirdPartyAppAuthentication.deepLinkURL {
                UIApplication.shared.open(deepLinkURL)
            }
        case .updating(let status):
            self.showUpdating(status: status)
        }
    }
    
    private func onCompletion(result: Result<Credential, Error>) {
        navigationItem.rightBarButtonItem = doneBarButtonItem

        switch result {
        case .failure(let error):
            showUpdating(status: error.localizedDescription)
        case .success(let credential):
            showCredentialUpdated(for: credential)
        }
    }
}

// MARK: - Navigation
extension AddCredentialViewController {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        hideUpdatingView()
        let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        supplementalInformationViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: supplementalInformationViewController)
        show(navigationController, sender: nil)
    }
    
    private func showUpdating(status: String) {
        if statusViewController == nil {
            let statusViewController = AddCredentialStatusViewController()
            statusViewController.modalTransitionStyle = .crossDissolve
            statusViewController.modalPresentationStyle = .overFullScreen
            present(statusViewController, animated: true)
            self.statusViewController = statusViewController
        }
        statusViewController?.status = status
    }
    
    private func hideUpdatingView() {
        guard statusViewController != nil else { return }
        dismiss(animated: true)
        statusViewController = nil
    }
    
    private func showCredentialUpdated(for credential: Credential) {
        hideUpdatingView()
        let finishedCredentialUpdatedViewController = FinishedCredentialUpdatedViewController(credential: credential)
        show(finishedCredentialUpdatedViewController, sender: nil)
    }
}

// MARK: - TextFieldCellDelegate
extension AddCredentialViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.item].text = text
        navigationItem.rightBarButtonItem?.isEnabled = form.fields[indexPath.item].isValueValid
    }
}

// MARK: - SupplementalInformationViewControllerDelegate
extension AddCredentialViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential) {
        dismiss(animated: true)
        // TODO: Maybe show loading
    }
}
