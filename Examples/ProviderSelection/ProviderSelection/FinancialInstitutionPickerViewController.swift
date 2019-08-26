import UIKit
/**
 Example of how to use the provider grouped by financialInstitution
 */
final class FinancialInstitutionPickerViewController: UITableViewController {
    
    var providerGroupedByFinancialInsititutions: [ProviderGroupedByFinancialInsititution]?

    private var selectedProviderGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    private var selectedProviders: [Provider]?
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerGroupedByFinancialInsititutions?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = providerGroupedByFinancialInsititutions?[indexPath.row].financialInsititutionID ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providersWithSameFinancialInstitution = providerGroupedByFinancialInsititutions![indexPath.row]
        switch providersWithSameFinancialInstitution {
        case .multipleAccessTypes(let providerGroupedByAccessTypes):
            self.selectedProviderGroupedByAccessTypes = providerGroupedByAccessTypes
            showAccessTypePicker(for: providerGroupedByAccessTypes)
        case .multipleCredentialTypes(let providers):
            self.selectedProviders = providers
            showCredentialTypePicker(for: providers)
        case .singleProvider(let provider):
            showAddCredential(for: provider)
        }
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
