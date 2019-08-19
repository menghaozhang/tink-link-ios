import SwiftProtobuf

internal extension UpdateAccountRequest {
    var toGRPCUpdateAccountRequest: GRPCUpdateAccountRequest {
        var updateAccountRequest = GRPCUpdateAccountRequest()
        updateAccountRequest.accountID = accountID.rawValue
        updateAccountRequest.name = accountNameGoogleProtobuf
        updateAccountRequest.type = accountType.toGRPCType
        updateAccountRequest.favored = accountFavoredGoogleProtobuf
        updateAccountRequest.excluded = accountExcludedGoogleProtobuf
        updateAccountRequest.ownership = GRPCExactNumber(value: accountOwnership)
        return updateAccountRequest
    }
    
    var accountNameGoogleProtobuf: Google_Protobuf_StringValue {
        return Google_Protobuf_StringValue(accountName)
    }
    var accountFavoredGoogleProtobuf: Google_Protobuf_BoolValue {
        return Google_Protobuf_BoolValue(accountFavored)
    }
    var accountExcludedGoogleProtobuf: Google_Protobuf_BoolValue {
        return Google_Protobuf_BoolValue(accountExcluded)
    }
}
