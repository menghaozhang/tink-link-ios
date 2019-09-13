import UIKit
import TinkLink

final class FinishedCredentialUpdatedViewController: UITableViewController, AccountContextDelegate {
    var credential: Credential
    var accountContext: AccountContext
    var accounts: [Account] = []
    var numberFormatter: NumberFormatter = NumberFormatter()
    
    init(credential: Credential) {
        self.credential = credential
        accountContext = AccountContext()
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountContext.delegate = self
        
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        
        navigationItem.title = "Accounts"
        navigationItem.largeTitleDisplayMode = .never
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        tableView.register(ValueTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ValueTableViewCell
        cell.textLabel?.text = accounts[indexPath.item].name
        cell.detailTextLabel?.text = numberFormatter.string(from: NSNumber(value: accounts[indexPath.item].balance.value.doubleValue))
        return cell
    }
    
    // MARK: - AccountContextDelegate
    func accountContext(_ store: AccountContext, didUpdateAccounts accounts: [Identifier<Credential> : [Account]]) {
        self.accounts = accounts[credential.id] ?? []
        tableView.reloadData()
        navigationItem.rightBarButtonItem = nil
    }
    
    func accountContext(_ store: AccountContext, didReceiveError error: Error) {
        // TODO: Handle Error
    }
}
