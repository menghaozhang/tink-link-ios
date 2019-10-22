import TinkLink
import UIKit

/// Example of how to use the provider grouped by financialInstitution
final class FinancialInstitutionPickerViewController: UITableViewController {
    var financialInstitutionGroups: [FinancialInstitution] = []
}

// MARK: - View Lifecycle

extension FinancialInstitutionPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.prompt = "Choose Financial Institution"
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: - UITableViewDataSource

extension FinancialInstitutionPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = financialInstitutionGroups[indexPath.row].financialInstitution.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionGroup = financialInstitutionGroups[indexPath.row]
        switch financialInstitutionGroup {
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionGroup.financialInstitution.name)
        case .credentialKinds(let groups):
            showCredentialKindPicker(for: groups, title: financialInstitutionGroup.financialInstitution.name)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation

extension FinancialInstitutionPickerViewController {
    func showAccessTypePicker(for groups: [AccessTypeGroup], title: String?) {
        let viewController = AccessTypePickerViewController(style: .plain)
        viewController.title = title
        viewController.providerAccessTypeGroups = groups
        show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for groups: [CredentialKindGroup], title: String?) {
        let viewController = CredentialKindPickerViewController(style: .plain)
        viewController.title = title
        viewController.providerCredentialKindGroups = groups
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}
