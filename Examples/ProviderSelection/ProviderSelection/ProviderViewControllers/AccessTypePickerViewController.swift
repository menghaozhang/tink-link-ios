import UIKit
/**
 Example of how to use the provider grouped by access type
 */
final class AccessTypePickerViewController: UITableViewController {
    
    var providerAccessTypeGroups: [ProviderAccessTypeGroup] = []
}

// MARK: - View Lifecycle
extension AccessTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Access Type"

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
        cell.textLabel?.text = providerAccessTypeGroups[indexPath.row].accessType
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let providersWithSameAccessType = providerAccessTypeGroups[indexPath.row]
        switch providersWithSameAccessType {
        case .credentialTypes(let providers):
            showCredentialTypePicker(for: providers)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation
extension AccessTypePickerViewController {
    func showCredentialTypePicker(for providers: [Provider]) {
        let viewController = CredentialTypePickerViewController(style: .plain)
        viewController.providers = providers
        show(viewController, sender: nil)
    }
    
    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: self)
    }
}
