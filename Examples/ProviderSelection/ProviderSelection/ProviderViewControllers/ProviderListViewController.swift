import TinkLink
import UIKit

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {
    private let providerContext = ProviderContext()
    
    private let searchController = UISearchController(searchResultsController: nil)

    private var financialInstitutionGroups: [FinancialInstitutionGroup] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var providerCanceller: Cancellable?

    override init(style: UITableView.Style) {
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

        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: Provider.Kind.all, accessTypes: Provider.AccessType.all)
        providerCanceller = providerContext.fetchProviders(attributes: attributes) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let providers = try result.get()
                    self?.financialInstitutionGroups = FinancialInstitutionGroup.makeGroups(providers: providers)
                } catch {
                    // TODO: Handle Error
                    print(error.localizedDescription)
                }
            }
        }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension ProviderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = financialInstitutionGroups[indexPath.row]
        cell.textLabel?.text = group.displayName
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = financialInstitutionGroups[indexPath.row]
        switch providerGroup {
        case .financialInstitutions(let financialInstitutionGroups):
            showFinancialInstitution(for: financialInstitutionGroups, title: providerGroup.displayName)
        case .accessTypes(let accessTypeGroups):
            showAccessTypePicker(for: accessTypeGroups, title: providerGroup.displayName)
        case .credentialKinds(let groups):
            showCredentialKindPicker(for: groups)
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

    func showCredentialKindPicker(for groups: [ProviderCredentialKindGroup]) {
        let viewController = CredentialKindPickerViewController(style: .plain)
        viewController.providerCredentialKindGroups = groups
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        let addCredentialViewController = AddCredentialViewController(provider: provider)
        show(addCredentialViewController, sender: nil)
    }
}

// MARK: - UISearchResultsUpdating

extension ProviderListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            financialInstitutionGroups = financialInstitutionGroups.filter { $0.displayName.localizedCaseInsensitiveContains(text) }
        }
    }
}
