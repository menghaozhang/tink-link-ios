import UIKit

struct Client {
    let clientId: String
}
/**
 Example of how to use the provider grouped by names
 */
final class ProviderListViewController: UITableViewController {
    var providerContext: ProviderContext?

    private var selectedProviderGroupedByFinancialInsititutions: [ProviderGroupedByFinancialInsititution]?
    private var selectedProviderGroupedByAccessTypes: [ProviderGroupedByAccessType]?
    private var selectedProviders: [Provider]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let client = TinkLink.shared.client
        //        providerContext = TinkLink.shared.makeProviderContext()
        
        let client = Client(clientId: "123")
        
        providerContext = ProviderContext(client: client)
        providerContext?.delegate = self
        //        providerContext.types = []
        //        providerContext.performFetch()
    }
    
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
            self.selectedProviderGroupedByFinancialInsititutions = providerGroupedByFinancialInsititutions
            showFinancialInstitution(for: providerGroupedByFinancialInsititutions)
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
    
    func showFinancialInstitution(for providerGroup: [ProviderGroupedByFinancialInsititution]) {
        performSegue(withIdentifier: "FinancialInstitutionPicker", sender: self)
    }
    
    func showAccessTypePicker(for providerGroup: [ProviderGroupedByAccessType]) {
        performSegue(withIdentifier: "AccessTypePicker", sender: self)
    }
    
    func showCredentialTypePicker(for providerGroup: [Provider]) {
        performSegue(withIdentifier: "CredentialTypePicker", sender: self)
    }
    
    func showAddCredential(for providerGroup: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: providerGroup)
        show(addCredentialViewController, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let financialInstitutionPickerViewController = segue.destination as? FinancialInstitutionPickerViewController {
            financialInstitutionPickerViewController.providerGroupedByFinancialInsititutions = selectedProviderGroupedByFinancialInsititutions
        } else if let accessTypePickerViewController = segue.destination as? AccessTypePickerViewController {
            accessTypePickerViewController.providerGroupedByAccessTypes = selectedProviderGroupedByAccessTypes
        } else if let credentialTypePickerViewController = segue.destination as? CredentialTypePickerViewController  {
            credentialTypePickerViewController.providers = selectedProviders
        }
    }
}

extension ProviderListViewController: ProviderContextDelegate {
    func providersDidChange(_ context: ProviderContext) {
        tableView.reloadData()
    }
}
