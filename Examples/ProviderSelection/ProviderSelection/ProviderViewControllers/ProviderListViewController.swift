import TinkLink
import UIKit

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {
    private var providerContext: ProviderContext?
    private let userContext = UserContext()
    private var user: User?
    
    private let searchController = UISearchController(searchResultsController: nil)

    private var originalFinancialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = []

    private var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fetchProviders() {
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: .all, accessTypes: .all)
        providerContext?.fetchProviders(attributes: attributes, completion: { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let providers = try result.get()
                    self?.financialInstitutionGroupNodes = ProviderTree(providers: providers).financialInstitutionGroups
                    self?.originalFinancialInstitutionGroupNodes = ProviderTree(providers: providers).financialInstitutionGroups
                } catch {
                    // TODO: Handle Error
                    print(error.localizedDescription)
                }
            }
        })
    }
}

// MARK: - View Lifecycle

extension ProviderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        userContext.createTemporaryUser(for: Market(code: "SE"), locale: TinkLink.defaultLocale) { [weak self] result in
            do {
                let user = try result.get()
                self?.user = user
                self?.providerContext = ProviderContext(user: user)
                self?.fetchProviders()
            } catch {
                // TODO: Handle Error
                print(error.localizedDescription)
            }
        }

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        title = "Choose Bank"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroupNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = financialInstitutionGroupNodes[indexPath.row]
        cell.textLabel?.text = group.displayName
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let financialInstitutionGroupNode = financialInstitutionGroupNodes[indexPath.row]
        switch financialInstitutionGroupNode {
        case .financialInstitutions(let financialInstitutionGroups):
            showFinancialInstitution(for: financialInstitutionGroups, title: financialInstitutionGroupNode.displayName)
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionGroupNode.displayName)
        case .credentialKinds(let groups):
            showCredentialKindPicker(for: groups)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation

extension ProviderListViewController {
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?) {
        guard let user = user else { return }
        let viewController = FinancialInstitutionPickerViewController(user: user)
        viewController.title = title
        viewController.financialInstitutionNodes = financialInstitutionNodes
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        guard let user = user else { return }
        let viewController = AccessTypePickerViewController(user: user)
        viewController.title = title
        viewController.accessTypeNodes = accessTypeNodes
        show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode]) {
        guard let user = user else { return }
        let viewController = CredentialKindPickerViewController(user: user)
        viewController.credentialKindNodes = credentialKindNodes
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        guard let user = user else { return }
        let addCredentialViewController = AddCredentialViewController(provider: provider, user: user)
        show(addCredentialViewController, sender: nil)
    }
}

// MARK: - UISearchResultsUpdating

extension ProviderListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            financialInstitutionGroupNodes = originalFinancialInstitutionGroupNodes.filter { $0.displayName.localizedCaseInsensitiveContains(text) }
        } else {
            financialInstitutionGroupNodes = originalFinancialInstitutionGroupNodes
        }
    }
}
