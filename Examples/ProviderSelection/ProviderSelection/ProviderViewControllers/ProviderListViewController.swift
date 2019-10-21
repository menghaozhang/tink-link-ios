import TinkLink
import UIKit

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {
    private let providerContext: ProviderContext
    
    private let searchController = UISearchController(searchResultsController: nil)

    private var providerGroups: [FinancialInstitutionGroup] {
        didSet {
            tableView.reloadData()
        }
    }

    override init(style: UITableView.Style) {
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: Provider.Kind.all, accessTypes: Provider.AccessType.all)
        providerContext = ProviderContext(attributes: attributes)
        providerGroups = providerContext.providerGroups
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension ProviderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        title = "Choose Bank"
        providerContext.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = providerGroups[indexPath.row]
        cell.textLabel?.text = group.displayName
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = providerGroups[indexPath.row]
        switch providerGroup {
        case .financialInstitutions(let financialInstitutionGroups):
            showFinancialInstitution(for: financialInstitutionGroups, title: providerGroup.displayName)
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: providerGroup.displayName)
        case .credentialTypes(let groups):
            showCredentialTypePicker(for: groups)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation

extension ProviderListViewController {
    func showFinancialInstitution(for groups: [FinancialInstitution], title: String?) {
        let viewController = FinancialInstitutionPickerViewController(style: .plain)
        viewController.title = title
        viewController.financialInstitutionGroups = groups
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for groups: [ProviderAccessTypeGroup], title: String?) {
        let viewController = AccessTypePickerViewController(style: .plain)
        viewController.title = title
        viewController.providerAccessTypeGroups = groups
        show(viewController, sender: nil)
    }

    func showCredentialTypePicker(for providers: [CredentialKindGroup]) {
        let viewController = CredentialTypePickerViewController(style: .plain)
        viewController.credentialKindGroups = providers
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}

// MARK: - ProviderContextDelegate

extension ProviderListViewController: ProviderContextDelegate {
    func providerContextDidChangeProviders(_ context: ProviderContext) {
        DispatchQueue.main.async {
            self.providerGroups = context.providerGroups
        }
    }

    func providerContext(_ context: ProviderContext, didReceiveError error: Error) {
        // TODO: Handle Error
        print(error)
    }
}

// MARK: - UISearchResultsUpdating

extension ProviderListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            providerGroups = providerContext.search(text)
        }
    }
}
