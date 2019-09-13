import UIKit
import TinkLink

/// Example of how to use the provider grouped by financialInstitution
final class FinancialInstitutionPickerViewController: UITableViewController {
    
    var financialInsititutionGroups: [FinancialInsititutionGroup] = []
}

// MARK: - View Lifecycle
extension FinancialInstitutionPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Financial Institution"
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource
extension FinancialInstitutionPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInsititutionGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = financialInsititutionGroups[indexPath.row].financialInsititutionName
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providersWithSameFinancialInstitution = financialInsititutionGroups[indexPath.row]
        switch providersWithSameFinancialInstitution {
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups)
        case .credentialTypes(let providers):
            showCredentialTypePicker(for: providers)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation
extension FinancialInstitutionPickerViewController {
    func showAccessTypePicker(for groups: [ProviderAccessTypeGroup]) {
        let viewController = AccessTypePickerViewController(style: .plain)
        viewController.providerAccessTypeGroups = groups
        show(viewController, sender: nil)
    }
    
    func showCredentialTypePicker(for providers: [Provider]) {
        let viewController = CredentialTypePickerViewController(style: .plain)
        viewController.providers = providers
        show(viewController, sender: nil)
    }
    
    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}
