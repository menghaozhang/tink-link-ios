import SwiftGRPC
import SwiftProtobuf

public final class AccountService {
    let channel: Channel
    
    init(channel: Channel) {
        self.channel = channel
    }
    
    private lazy var service = AccountServiceServiceClient(channel: channel)
    
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

public struct UpdateAccountRequest {
    enum AccountOwnership: Double {
        case owned = 1
        case shared = 0.5
    }
    
    var accountID: String
    var accountName: String
    var accountType: GRPCAccount.TypeEnum
    var accountFavored: Bool
    var accountExcluded: Bool
    var accountOwnership: AccountOwnership
    var accountExclusionType: GRPCAccount.Exclusion
    
    init(accountID: String, accountName: String, accountType: GRPCAccount.TypeEnum, accountFavored: Bool = fasle, accountExcluded: Bool = false, accountOwnership: AccountOwnership = .owned, accountExclusionType: GRPCAccount.Exclusion = .unkown) {
        self.accountID = accountID
        self.accountName = accountName
        self.accountType = accountType
        self.accountFavored = accountFavored
        self.accountExcluded = accountExcluded
        self.accountOwnership = accountOwnership
        self.accountExclusionType = accountExclusionType
    }
}
