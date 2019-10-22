import TinkLink
import UIKit

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {
    private let userContext = UserContext()
    private var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                DispatchQueue.main.async {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.tinkAccessToken = accessToken
                    }
                }
                fetchProvider(with: accessToken)
            }
        }
    }
    private var providerContext: ProviderContext?
    private var userCancellable: RetryCancellable?
    private var providerCancellable: RetryCancellable?
    
    private let searchController = UISearchController(searchResultsController: nil)

    private var providerGroups: [ProviderGroup] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    private var providerCanceller: Cancellable?

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fetchProvider(with accessToken: AccessToken) {
        let a = ProviderContext.Attributes(capabilities: .all, kinds: Provider.Kind.all, accessTypes: Provider.AccessType.all)
        providerContext = ProviderContext(accessToken: accessToken)
        providerCancellable = providerContext?.fetchProviders(attributes: a, completion: { [weak self] result in
            if let providers = try? result.get() {
                DispatchQueue.main.async {
                    self?.providerGroups = ProviderGroup.makeGroups(providers: providers)
                }
            }
            self?.providerCancellable = nil
        })
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

        let configuration = TinkLink.shared.configuration
        userCancellable = userContext.authenticateIfNeeded(for: configuration.market, locale: configuration.locale) { [weak self] result in
            if let accessToken = try? result.get() {
                self?.accessToken = accessToken
            }
            self?.userCancellable = nil
        }

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
        case .credentialKinds(let providers):
            showCredentialKindPicker(for: providers)
        case .provider(let provider):
            showAddCredential(for: provider)
        }
    }
}

// MARK: - Navigation

extension ProviderListViewController {
    func showFinancialInstitution(for groups: [FinancialInstitutionGroup], title: String?) {
        guard let accessToken = accessToken else {
            preconditionFailure("accessToken should not be nil")
        }
        let viewController = FinancialInstitutionPickerViewController(accessToken: accessToken, style: .plain)
        viewController.title = title
        viewController.financialInstitutionGroups = groups
        show(viewController, sender: nil)
    }

    func showAccessTypePicker(for groups: [ProviderAccessTypeGroup], title: String?) {
        guard let accessToken = accessToken else {
            preconditionFailure("accessToken should not be nil")
        }
        let viewController = AccessTypePickerViewController(accessToken: accessToken,style: .plain)
        viewController.title = title
        viewController.providerAccessTypeGroups = groups
        show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for providers: [Provider]) {
        guard let accessToken = accessToken else {
            preconditionFailure("accessToken should not be nil")
        }
        let viewController = CredentialKindPickerViewController(accessToken: accessToken, style: .plain)
        viewController.providers = providers
        show(viewController, sender: nil)
    }

    func showAddCredential(for provider: Provider) {
        guard let accessToken = accessToken else {
            preconditionFailure("accessToken should not be nil")
        }
        let addCredentialViewController = AddCredentialViewController(provider: provider, accessToken: accessToken)
        show(addCredentialViewController, sender: nil)
    }
}

// MARK: - UISearchResultsUpdating

extension ProviderListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            providerGroups = providerGroups.filter { $0.displayName.localizedCaseInsensitiveContains(text) }
        }
    }
}
