import UIKit
import TinkLink

/// Example of how to use the provider field specification to add credential
final class AddCredentialViewController: UITableViewController {
    var credentialContext: CredentialContext?
    let provider: Provider

    private var form: Form
    private var formError: Form.ValidationError? {
        didSet {
            tableView.reloadData()
        }
    }
    private var task: AddCredentialTask?
    private var statusViewController: AddCredentialStatusViewController?
    private lazy var addBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addCredential))
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
        navigationItem.rightBarButtonItem = addBarButtonItem
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return form.fields.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath)
        let field = form.fields[indexPath.section]
        if let textFieldCell = cell as? TextFieldCell {
            textFieldCell.delegate = self
            textFieldCell.textField.placeholder = field.attributes.placeholder
            textFieldCell.textField.isSecureTextEntry = field.attributes.isSecureTextEntry
            textFieldCell.textField.isEnabled = field.attributes.isEditable
            textFieldCell.textField.text = field.text
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let field = form.fields[section]
        return field.attributes.description
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let error = formError {
            let field = form.fields[section]
            if let fieldError = error[fieldName: field.name] {
                return fieldError.errorDescription
            } else {
                return nil
            }
        } else if section == form.fields.count - 1 {
            return provider.helpText
        } else {
            return nil
        }
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
            try form.validateFields()
            task = credentialContext?.addCredential(for: provider, form: form,
                progressHandler: { [weak self] status in
                    self?.onUpdate(for: status)
                },
                completion: { [weak self] result in
                    self?.onCompletion(result: result)
            })
        } catch {
            formError = error as? Form.ValidationError
        }
    }
    
    private func onUpdate(for status: AddCredentialTask.Status) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            self.showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication):
            if let deepLinkURL = thirdPartyAppAuthentication.deepLinkURL, UIApplication.shared.canOpenURL(deepLinkURL) {
                UIApplication.shared.open(deepLinkURL)
            } else {
                showDownloadPrompt(for: thirdPartyAppAuthentication)
            }
        case .updating(let status):
            self.showUpdating(status: status)
        }
    }
    
    private func onCompletion(result: Result<Credential, Error>) {
        navigationItem.rightBarButtonItem = addBarButtonItem

        switch result {
        case .failure(let error):
            hideUpdatingView(animated: true) {
                self.showAlert(for: error)
            }
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
            navigationItem.setRightBarButton(addBarButtonItem, animated: true)
            let statusViewController = AddCredentialStatusViewController()
            statusViewController.modalTransitionStyle = .crossDissolve
            statusViewController.modalPresentationStyle = .overFullScreen
            present(statusViewController, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.view.tintAdjustmentMode = .dimmed
            }
            self.statusViewController = statusViewController
        }
        statusViewController?.status = status
    }
    
    private func hideUpdatingView(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard statusViewController != nil else { return }
        UIView.animate(withDuration: 0.3) {
            self.view.tintAdjustmentMode = .automatic
        }
        dismiss(animated: animated, completion: completion)
        statusViewController = nil
    }
    
    private func showCredentialUpdated(for credential: Credential) {
        hideUpdatingView()
        let finishedCredentialUpdatedViewController = FinishedCredentialUpdatedViewController(credential: credential)
        show(finishedCredentialUpdatedViewController, sender: nil)
    }

    private func showDownloadPrompt(for thirdPartyAppAuthentication: Credential.ThirdPartyAppAuthentication) {
        let alertController = UIAlertController(title: thirdPartyAppAuthentication.downloadTitle, message: thirdPartyAppAuthentication.downloadMessage, preferredStyle: .alert)

        if let appStoreURL = thirdPartyAppAuthentication.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
                if let appStoreURL = thirdPartyAppAuthentication.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
                    UIApplication.shared.open(appStoreURL)
                }
            })
            alertController.addAction(cancelAction)
            alertController.addAction(downloadAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
        }

        present(alertController, animated: true)
    }

    private func showAlert(for error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}

// MARK: - TextFieldCellDelegate
extension AddCredentialViewController: TextFieldCellDelegate {
    func textFieldCell(_ cell: TextFieldCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.section].text = text
        navigationItem.rightBarButtonItem?.isEnabled = form.fields[indexPath.section].isValid
    }
}

// MARK: - SupplementalInformationViewControllerDelegate
extension AddCredentialViewController: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential) {
        dismiss(animated: true)

        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
}
