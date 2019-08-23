import UIKit
/**
 Example of how to use the provider grouped by access type
 */
final class AccessTypePickerViewController: UITableViewController {
    
    var providerGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    
    var providers: [Provider]?
    var provider: Provider?
    
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
            self.providers = providers
            showCredentialTypePicker(for: providers)
        case .singleProvider(let provider):
            self.provider = provider
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
        if let credentialTypePickerViewController = segue.destination as? CredentialTypePickerViewController  {
            credentialTypePickerViewController.providers = providers
        } else if let addCredentialViewController = segue.destination as? AddCredentialViewController {
            addCredentialViewController.provider = provider
        }
    }
}
