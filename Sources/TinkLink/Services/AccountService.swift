import SwiftGRPC
import SwiftProtobuf

public final class AccountService {
    let channel: Channel
    
    init(channel: Channel) {
        self.channel = channel
    }
    
    private lazy var service = AccountServiceServiceClient(channel: channel)
    
    /// Lists all accounts
    ///
    /// - Parameter completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func listAccounts(completion: @escaping (Result<[GRPCAccount], Error>) -> Void) -> Cancellable {
        let request = GRPCListAccountsRequest()
        
        let canceller = CallCanceller()
        do {
            canceller.call = try service.listAccounts(request) { (response, callResult) in
                if let response = response {
                    completion(.success(response.accounts))
                } else {
                    let error = RPCError.callError(callResult)
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
        
        return canceller
    }
    
    /// Updates an account
    ///
    /// - Parameters:
    ///     - request: The request to update the account with matching account ID.
    ///     - completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func updateAccount(request: UpdateAccountRequest, completion: @escaping (Result<GRPCAccount, Error>) -> Void) -> Cancellable {
        var updateAccountRequest = GRPCUpdateAccountRequest()
        updateAccountRequest.accountID = request.accountID
        updateAccountRequest.name = Google_Protobuf_StringValue(request.accountName)
        updateAccountRequest.type = request.accountType
        updateAccountRequest.favored = Google_Protobuf_BoolValue(request.accountFavored)
        updateAccountRequest.excluded = Google_Protobuf_BoolValue(request.accountExcluded)
        updateAccountRequest.ownership = GRPCExactNumber(value: Decimal(request.accountOwnership.rawValue))
        
        let canceller = CallCanceller()
        
        do {
            canceller.call = try service.updateAccount(updateAccountRequest) { (response, callResult) in
                if let response = response {
                    completion(.success(response.account))
                } else {
                    let error = RPCError.callError(callResult)
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
        
        return canceller
    }
}
