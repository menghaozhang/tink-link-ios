import UIKit
import TinkLink

/**
 Example of how to use the provider field specification to add credential
 */
final class AddCredentialViewController: UITableViewController {
    var credentialContext: CredentialContext?
    var provider: Provider
    
    private var statusViewController: AddCredentialStatusViewController?

    private lazy var doneBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addCredential))
    
    init(provider: Provider) {
        self.provider = provider
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
        navigationItem.rightBarButtonItem = doneBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = false
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
            textFieldCell.textField.isEnabled = !field.isImmutable || field.value.isEmpty
            textFieldCell.textField.text = field.value
        }
        return cell
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
            try provider.fields.validateValues()
            credentialContext?.addCredential(for: provider, fields: provider.fields, progressHandler: onUpdate, completion: onCompletion)
        } catch let error as FieldSpecificationsError {
            print(error.errors)
        } catch {
            print(error)
        }
    }
    
    private func onUpdate(for status: CredentialContext.AddCredentialStatus) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyURL):
            UIApplication.shared.open(thirdPartyURL)
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
        show(navigationController, sender: self)
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
        show(finishedCredentialUpdatedViewController, sender: self)
    }
}

// MARK: - TextFieldCellDelegate
extension AddCredentialViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        provider.fields[indexPath.item].value = text
        navigationItem.rightBarButtonItem?.isEnabled = provider.fields[indexPath.item].isValueValid
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
