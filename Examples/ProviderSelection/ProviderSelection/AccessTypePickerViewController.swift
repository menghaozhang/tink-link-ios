import UIKit

protocol ProviderGroupedByAccessTypeOverview: AnyObject {
    var providerGroupedByAccessTypes: [ProviderGroupedByAccessType]? { get set }
}

class AccessTypePickerViewController: UITableViewController, ProviderGroupedByAccessTypeOverview {
    
    var providerGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    
    var providersOverview: ProvidersWithCredentialTypeOverview?
    
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
        case .multipleCredentialTypes(let providerGroupedByCredentialTypes):
            showCredentialTypePicker(for: providerGroupedByCredentialTypes)
        case .singleProvider(let provider):
            showAddCredential(for: provider)
        }
    }
    
    func showCredentialTypePicker(for providerGroup: [Provider]) {
        performSegue(withIdentifier: "CredentialTypePicker", sender: self)
    }
    
    func showAddCredential(for providerGroup: Provider) {
        performSegue(withIdentifier: "AddCredential", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let providerGroupOverview = segue.destination as? ProvidersWithCredentialTypeOverview  {
            providerGroupOverview.providers = providersOverview?.providers
        }
    }
}
