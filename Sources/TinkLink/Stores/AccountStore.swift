import Foundation

final class AccountStore {
    static let shared: AccountStore = AccountStore()
    
    private init() {
        service = TinkLink.shared.client.accountService
        authenticationManager = AuthenticationManager.shared
    }
    
    private let authenticationManager: AuthenticationManager
    private let dispatchGroup = DispatchGroup()
    private var service: AccountService
    private var listAccountCanceller: Cancellable?
    
    var accounts: [Account]? {
        didSet {
            NotificationCenter.default.post(name: .accountStoreChanged, object: self)
        }
    }
    
    func performListAccountsIfNeeded() {
        authenticationManager.authenticateIfNeeded { [weak self] _ in
            guard let self = self, self.listAccountCanceller == nil else {
                return
            }
            let cancellable = self.service.listAccounts { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let accounts):
                        self.accounts = accounts
                    case .failure(let error):
                        break
                        // Handle error
                    }
                    self.listAccountCanceller = nil
                }
            }
            self.listAccountCanceller = cancellable
        }
    }
}

extension Notification.Name {
    static let accountStoreChanged = Notification.Name("TinkLinkAccountStoreChangedNotificationName")
}
