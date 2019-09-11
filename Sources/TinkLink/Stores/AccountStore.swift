import Foundation

final class AccountStore {
    static let shared: AccountStore = AccountStore()
    
    private init() {
        service = TinkLink.shared.client.accountService
    }
    
    private var service: AccountService
    private var listAccountCanceller: Cancellable?
    
    var accounts: [Account] = [] {
        didSet {
            NotificationCenter.default.post(name: .accountStoreChanged, object: self)
        }
    }
    
    func performListAccountsIfNeeded() {
        guard listAccountCanceller == nil else {
            return
        }
        let cancellable = service.listAccounts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accounts):
                    self?.accounts = accounts
                case .failure(let error):
                    break
                    // Handle error
                }
                self?.listAccountCanceller = nil
            }
        }
        listAccountCanceller = cancellable
    }
}

extension Notification.Name {
    static let accountStoreChanged = Notification.Name("TinkLinkAccountStoreChangedNotificationName")
}
