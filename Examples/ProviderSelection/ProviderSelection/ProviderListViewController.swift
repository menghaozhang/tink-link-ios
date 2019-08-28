import UIKit

/**
 Example of how to use the provider grouped by names
 */
final class ProviderListViewController: UITableViewController {
    var providerContext: ProviderContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose your bank"
        
        let client = Client(clientId: "123")
        
        providerContext = ProviderContext(client: client)
        providerContext?.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource
extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerContext!.providerGroupsByGroupedName.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = providerContext!.providerGroupsByGroupedName[indexPath.item]
        cell.textLabel?.text = group.groupedName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = providerContext!.providerGroupsByGroupedName[indexPath.item]
        switch providerGroup {
        case .financialInsititutions(let providerGroupedByFinancialInsititutions):
            showFinancialInstitution(for: providerGroupedByFinancialInsititutions)
        case .accessTypes(let providerGroupedByAccessTypes):
            showAccessTypePicker(for: providerGroupedByAccessTypes)
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

extension ProviderListViewController: ProviderContextDelegate {
    func providersDidChange(_ context: ProviderContext) {
        tableView.reloadData()
    }
}
