import UIKit
/**
 Example of how to use the provider grouped by financialInstitution
 */
final class FinancialInstitutionPickerViewController: UITableViewController {
    
    var providerGroupedByFinancialInsititutions: [ProviderGroupedByFinancialInsititution]?
    var providerGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    var providers: [Provider]?
    var provider: Provider?
    
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
            self.providerGroupedByAccessTypes = providerGroupedByAccessTypes
            showAccessTypePicker(for: providerGroupedByAccessTypes)
        case .multipleCredentialTypes(let providers):
            self.providers = providers
            showCredentialTypePicker(for: providers)
        case .singleProvider(let provider):
            self.provider = provider
            showAddCredential(for: provider)
        }
    }
    
    
    func showAccessTypePicker(for providerGroup: [ProviderGroupedByAccessType]) {
        performSegue(withIdentifier: "AccessTypePicker", sender: self)
    }
    
    func showCredentialTypePicker(for providerGroup: [Provider]) {
        performSegue(withIdentifier: "CredentialTypePicker", sender: self)
    }
    
    func showAddCredential(for providerGroup: Provider) {
        performSegue(withIdentifier: "AddCredential", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let accessTypePickerViewController = segue.destination as? AccessTypePickerViewController {
            accessTypePickerViewController.providerGroupedByAccessTypes = providerGroupedByAccessTypes
        } else if let credentialTypePickerViewController = segue.destination as? CredentialTypePickerViewController {
            credentialTypePickerViewController.providers = providers
        } else if let addCredentialViewController = segue.destination as? AddCredentialViewController {
            addCredentialViewController.provider = provider
        }
    }
}
