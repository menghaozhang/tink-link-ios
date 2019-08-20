import UIKit

protocol ProviderGroupedByFinancialInsititutionOverview: AnyObject {
    var providerGroupedByFinancialInsititutions: [ProviderGroupedByFinancialInsititution]? { get set }
}

class FinancialInstitutionPickerViewController: UITableViewController, ProviderGroupedByFinancialInsititutionOverview {
    
    var providerGroupedByFinancialInsititutions: [ProviderGroupedByFinancialInsititution]?
    var providersOverview: (ProvidersWithCredentialTypeOverview & ProviderGroupedByAccessTypeOverview)?
    
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
        case .multupleAccessTypes(let providerGroupedByAccessTypes):
            providersOverview?.providerGroupedByAccessTypes = providerGroupedByAccessTypes
            showAccessTypePicker(for: providerGroupedByAccessTypes)
        case .multipleCredentialTypes(let providers):
            providersOverview?.providers = providers
            showCredentialTypePicker(for: providers)
        case .singleProvider(let provider):
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
        if let providerGroupOverview = segue.destination as? ProviderGroupedByAccessTypeOverview {
            providerGroupOverview.providerGroupedByAccessTypes = providersOverview?.providerGroupedByAccessTypes
        } else if let providerGroupOverview = segue.destination as? ProvidersWithCredentialTypeOverview  {
            providerGroupOverview.providers = providersOverview?.providers
        }
    }
}
