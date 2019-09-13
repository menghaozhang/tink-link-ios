import UIKit
import TinkLink

/// Example of how to use the provider grouped by names
final class ProviderListViewController: UITableViewController {
    private var market: Market
    var providerContext: ProviderContext {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var providerGroups: [ProviderGroup] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(market: Market, style: UITableView.Style) {
        self.market = market
        let attributes = ProviderContext.Attributes(capabilities: .checkingAccounts, includeTestProviders: false, accessTypes: Provider.AccessType.all, market: market)
        providerContext = ProviderContext(attributes: attributes)
        providerGroups = providerContext.providerGroups
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMarket(market: Market) {
        guard self.market != market else {
            return
        }
        self.market = market
        providerContext = ProviderContext(market: market)
        providerGroups = providerContext.providerGroups
        providerContext.delegate = self
    }
}

// MARK: - View Lifecycle
extension ProviderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let group = providerGroups[indexPath.item]
        cell.textLabel?.text = group.groupedDisplayName
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let providerGroup = providerGroups[indexPath.item]
        switch providerGroup {
        case .financialInsititutions(let financialInsititutionGroups):
            showFinancialInstitution(for: financialInsititutionGroups)
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
extension ProviderListViewController {
    func showFinancialInstitution(for groups: [FinancialInsititutionGroup]) {
        let viewController = FinancialInstitutionPickerViewController(style: .plain)
        viewController.financialInsititutionGroups = groups
        show(viewController, sender: nil)
    }
    
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

// MARK: - ProviderContextDelegate
extension ProviderListViewController: ProviderContextDelegate {
    func providerContext(_ context: ProviderContext, didUpdateProviders providers: [Provider]) {
        providerGroups = context.providerGroups
    }
    
    func providerContext(_ context: ProviderContext, didReceiveError error: Error) {
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
