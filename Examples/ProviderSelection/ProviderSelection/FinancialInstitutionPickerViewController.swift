import UIKit
/**
 Example of how to use the provider grouped by financialInstitution
 */
final class FinancialInstitutionPickerViewController: UITableViewController {
    
    var providerGroupedByFinancialInsititutions: [ProvidersGroupedByFinancialInsititution]?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Financial Institution"

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
        case .accessTypes(let providerGroupedByAccessTypes):
            showAccessTypePicker(for: providerGroupedByAccessTypes)
        case .credentialTypes(let providers):
            showCredentialTypePicker(for: providers)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
    
    func showAccessTypePicker(for providerGroup: [ProvidersGroupedByAccessType]) {
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
