import UIKit

final class CredentialTypePickerViewController: UITableViewController {
    
    var providers: [Provider]?
    var provider: Provider?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = providers?[indexPath.item].credentialType.rawValue ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let provider = providers![indexPath.row]
        self.provider = provider
        showAddCredential(for: provider)
    }
    
    func showAddCredential(for providerGroup: Provider) {
        performSegue(withIdentifier: "AddCredential", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addCredentialViewController = segue.destination as? AddCredentialViewController {
            addCredentialViewController.provider = provider
        }
    }
}
