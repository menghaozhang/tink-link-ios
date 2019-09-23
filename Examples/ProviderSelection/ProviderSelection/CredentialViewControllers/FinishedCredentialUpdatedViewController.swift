import UIKit
import TinkLink

struct Account {
    let name: String
    let balance: CurrencyDenominatedAmount
}

final class FinishedCredentialUpdatedViewController: UITableViewController {
    var credential: Credential

    init(credential: Credential) {
        self.credential = credential
        super.init(style: .grouped)

        // FIXME: Accounts need to be fetched using a customer backend
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Credential Added"
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.register(ValueTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ValueTableViewCell else {
            fatalError()
        }
        cell.textLabel?.text = credential.statusPayload
        return cell
    }
}
