import UIKit
/**
 Example of how to use the provider grouped by access type
 */
final class AccessTypePickerViewController: UITableViewController {
    
    var providerGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    
    private var selectedProviders: [Provider]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerGroupedByAccessTypes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = providerGroupedByAccessTypes?[indexPath.row].accessType ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let providersWithSameAccessType = providerGroupedByAccessTypes![indexPath.row]
        switch providersWithSameAccessType {
        case .multipleCredentialTypes(let providers):
            self.selectedProviders = providers
            showCredentialTypePicker(for: providers)
        case .singleProvider(let provider):
            showAddCredential(for: provider)
        }
    }
    
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
