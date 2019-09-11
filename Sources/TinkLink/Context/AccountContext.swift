public protocol AccountContextDelegate: AnyObject {
    func accountContext(_ store: AccountContext, didUpdateAccounts accounts: [Identifier<Credential>: [Account]])
    func accountContext(_ store: AccountContext, didReceiveError error: Error)
}

public class AccountContext {
    public init() {
        _accounts = Dictionary(grouping: accountStore.accounts, by: { $0.credentialID })
        accountStoreObserver = NotificationCenter.default.addObserver(forName: .accountStoreChanged, object: accountStore, queue: .main) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf._accounts = Dictionary(grouping: strongSelf.accountStore.accounts, by: { $0.credentialID })
        }
    }
    
    public weak var delegate: AccountContextDelegate? {
        didSet {
            if delegate != nil, _accounts == nil {
                performFetch()
            }
        }
    }
    
    private var _accounts: [Identifier<Credential>: [Account]]? {
        didSet {
            guard let accounts = _accounts else { return }
            delegate?.accountContext(self, didUpdateAccounts: accounts)
        }
    }
    
    private let accountStore = AccountStore.shared
    private var accountStoreObserver: Any?
    
    private func performFetch() {
        accountStore.performListAccountsIfNeeded()
    }
}

extension AccountContext {
    public subscript(_ id: Identifier<Credential>) -> [Account]? {
        guard let accounts = _accounts else {
            performFetch()
            return nil
        }
        return accounts[id]
    }
}
