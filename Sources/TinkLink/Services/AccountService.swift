import SwiftGRPC

public final class AccountService {
    let channel: Channel
    let clientKey: String
    
    init(channel: Channel, clientKey: String) {
        self.channel = channel
        self.clientKey = clientKey
    }
    
    internal lazy var service: AccountServiceServiceClient = {
        let service = AccountServiceServiceClient(channel: channel)
        do {
            try service.metadata.addTinkMetadata()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return service
    }()
    
    /// Lists all accounts
    ///
    /// - Parameter completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func listAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> Cancellable {
        let request = GRPCListAccountsRequest()
        
        return startCall(for: request, method: service.listAccounts, responseMap: { $0.accounts.map(Account.init) }, completion: completion)
    }
    
    /// Updates an account
    ///
    /// - Parameters:
    ///     - request: The request to update the account with matching account ID.
    ///     - completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func updateAccount(request: UpdateAccountRequest, completion: @escaping (Result<Account, Error>) -> Void) -> Cancellable {
        let updateAccountRequest = request.grpcUpdateAccountRequest
        
        return startCall(for: updateAccountRequest, method: service.updateAccount, responseMap: { Account(grpcAccount: $0.account) }, completion: completion)
    }
}
