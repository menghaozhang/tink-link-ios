import UIKit

/**
 Example of how to use the provider grouped by names
 */
final class ProviderListViewController: UITableViewController {
    var providerStore: ProviderStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        providerStore = ProviderStore(market: "SE")
        providerStore?.delegate = self
        
        title = "Choose your bank"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerStore!.providerGroupsByGroupedName.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = providerStore!.providerGroupsByGroupedName[indexPath.item]
        cell.textLabel?.text = group.groupedName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = providerStore!.providerGroupsByGroupedName[indexPath.item]
        switch providerGroup {
        case .financialInsititutions(let providerGroupedByFinancialInsititutions):
            showFinancialInstitution(for: providerGroupedByFinancialInsititutions)
        case .multipleAccessTypes(let providerGroupedByAccessTypes):
            showAccessTypePicker(for: providerGroupedByAccessTypes)
        case .multipleCredentialTypes(let providers):
            showCredentialTypePicker(for: providers)
        case .singleProvider(let provider):
            showAddCredential(for: provider)
        }
    }
    
    func showFinancialInstitution(for providerGroup: [ProviderGroupedByFinancialInsititution]) {
        let viewController = FinancialInstitutionPickerViewController(style: .plain)
        viewController.providerGroupedByFinancialInsititutions = providerGroup
        show(viewController, sender: nil)
    }
    
    func showAccessTypePicker(for providerGroup: [ProviderGroupedByAccessType]) {
        let viewController = AccessTypePickerViewController(style: .plain)
        viewController.providerGroupedByAccessTypes = providerGroup
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
