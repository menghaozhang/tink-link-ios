import UIKit
/**
 Example of how to use the provider grouped by access type
 */
final class AccessTypePickerViewController: UITableViewController {
    
    var providerGroupedByAccessTypes: [ProvidersGroupedByAccessType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Access Type"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension AccessTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerGroupedByAccessTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = providerGroupedByAccessTypes[indexPath.row].accessType
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let providersWithSameAccessType = providerGroupedByAccessTypes[indexPath.row]
        switch providersWithSameAccessType {
        case .credentialTypes(let providers):
            showCredentialTypePicker(for: providers)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

extension AccessTypePickerViewController {
    func showCredentialTypePicker(for providerGroup: [Provider]) {
        let viewController = CredentialTypePickerViewController(style: .plain)
        viewController.providers = providerGroup
        show(viewController, sender: nil)
    }
    
    func showAddCredential(for providerGroup: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: providerGroup)
        show(addCredentialViewController, sender: self)
    }
}
