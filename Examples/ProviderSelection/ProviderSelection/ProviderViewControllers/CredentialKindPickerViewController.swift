import TinkLink
import UIKit

/// Example of how to use the provider grouped by credential type
final class CredentialKindPickerViewController: UITableViewController {
    var credentialKindGroups: [ProviderTree.CredentialKindGroup] = []
}

// MARK: - View Lifecycle

extension CredentialKindPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.prompt = "Choose Credential Type"
        navigationItem.title = credentialKindGroups.first?.provider.displayName
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension CredentialKindPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentialKindGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = credentialKindGroups[indexPath.row].displayDescription
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credentialKindGroup = credentialKindGroups[indexPath.row]
        showAddCredential(for: credentialKindGroup.provider)
    }
}

// MARK: - Navigation

extension CredentialKindPickerViewController {
    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}
