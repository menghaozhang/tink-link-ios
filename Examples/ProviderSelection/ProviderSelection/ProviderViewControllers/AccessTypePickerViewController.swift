import TinkLink
import UIKit

/// Example of how to use the provider grouped by access type
final class AccessTypePickerViewController: UITableViewController {
    var providerAccessTypeGroups: [ProviderAccessTypeGroup] = []
}

// MARK: - View Lifecycle

extension AccessTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.prompt = "Choose Access Type"
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension AccessTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerAccessTypeGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = providerAccessTypeGroups[indexPath.row].accessType.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerAccessTypeGroup = providerAccessTypeGroups[indexPath.row]
        switch providerAccessTypeGroup {
        case .credentialTypes(let groups):
            showCredentialTypePicker(for: groups)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation

extension AccessTypePickerViewController {
    func showCredentialTypePicker(for groups: [CredentialKindGroup]) {
        let viewController = CredentialTypePickerViewController(style: .plain)
        viewController.credentialKindGroups = groups
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}
