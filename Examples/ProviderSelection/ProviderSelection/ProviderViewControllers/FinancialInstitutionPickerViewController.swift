import TinkLink
import UIKit

/// Example of how to use the provider grouped by financialInstitution
final class FinancialInstitutionPickerViewController: UITableViewController {
    var financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode] = []
    private let user: User

    init(user: User) {
        self.user = user

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
        return financialInstitutionNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = financialInstitutionNodes[indexPath.row].financialInstitution.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionNode = financialInstitutionNodes[indexPath.row]
        switch financialInstitutionNode {
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionNode.financialInstitution.name)
        case .credentialKinds(let groups):
            showCredentialKindPicker(for: groups, title: financialInstitutionNode.financialInstitution.name)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation

extension FinancialInstitutionPickerViewController {
    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        let viewController = AccessTypePickerViewController(user: user)
        viewController.title = title
        viewController.accessTypeNodes = accessTypeNodes
        show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode], title: String?) {
        let viewController = CredentialKindPickerViewController(user: user)
        viewController.title = title
        viewController.credentialKindNodes = credentialKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider, user: user)
        show(addCredentialViewController, sender: nil)
    }
}
