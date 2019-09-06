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
            DispatchQueue.main.async {
                self.accountStoreObservers.forEach { (tokenId, handler) in
                    handler(tokenId)
                }
            }
        }
    }
    
    func performListAccountsIfNeeded() {
        guard listAccountCanceller == nil else {
            return
        }
        let cancellable = service.listAccounts { [weak self] result in
            switch result {
            case .success(let accounts):
                self?.accounts = accounts
            case .failure(let error):
                break
                // Handle error
            }
            self?.listAccountCanceller = nil
        }
        listAccountCanceller = cancellable
    }
    
    typealias ObserverHandler = (_ tokenIdentifier: UUID) -> Void
    // Provider Observer
    var accountStoreObservers: [UUID: ObserverHandler] = [:]
    func addAccountsObserver(token: StoreObserverToken, handler: @escaping ObserverHandler) {
        token.addReleaseHandler { [weak self] in
            self?.accountStoreObservers[token.identifier] = nil
        }
        accountStoreObservers[token.identifier] = handler
    }
}
