import UIKit

/**
 Example of how to use the provider grouped by credential type
 */
final class CredentialTypePickerViewController: UITableViewController {
    
    var providers: [Provider] = []
}

// MARK: - View Lifecycle
extension CredentialTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Credential Type"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource
extension CredentialTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = providers[indexPath.item].credentialType.rawValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let provider = providers[indexPath.row]
        showAddCredential(for: provider)
    }
}

// MARK: - Navigation
extension CredentialTypePickerViewController {
    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: self)
    }
}
