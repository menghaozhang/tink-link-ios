import UIKit

/**
 Example of how to use the provider grouped by names
 */
final class ProviderListViewController: UITableViewController {
    var providerStore: ProviderStore?
}

// MARK: - View Lifecycle
extension ProviderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        providerStore = ProviderStore(market: "SE")
        providerStore?.delegate = self
        
        title = "Choose your bank"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource
extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerStore!.providerGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = providerStore!.providerGroups[indexPath.item]
        cell.textLabel?.text = group.groupedName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = providerStore!.providerGroups[indexPath.item]
        switch providerGroup {
        case .financialInsititutions(let financialInsititutionGroups):
            showFinancialInstitution(for: financialInsititutionGroups)
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups)
        case .credentialTypes(let providers):
            showCredentialTypePicker(for: providers)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation
extension ProviderListViewController {
    func showFinancialInstitution(for providerGroup: [FinancialInsititutionGroup]) {
        let viewController = FinancialInstitutionPickerViewController(style: .plain)
        viewController.financialInsititutionGroups = providerGroup
        show(viewController, sender: nil)
    }
    
    func showAccessTypePicker(for providerGroup: [ProviderAccessTypeGroup]) {
        let viewController = AccessTypePickerViewController(style: .plain)
        viewController.providerAccessTypeGroups = providerGroup
        show(viewController, sender: nil)
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

extension ProviderListViewController: ProviderStoreDelegate {
    func providersStore(_ context: ProviderStore, didUpdateProviders providers: [Provider]) {
        if isViewLoaded {
            tableView.reloadData()
        }
    }
    
    func providersStore(_ context: ProviderStore, didReceiveError error: Error) {
        print(error)
    }
}
