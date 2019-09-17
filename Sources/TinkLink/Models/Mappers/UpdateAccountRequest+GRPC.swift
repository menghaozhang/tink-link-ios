import Foundation
import SwiftProtobuf

extension UpdateAccountRequest {
    var grpcUpdateAccountRequest: GRPCUpdateAccountRequest {
        var updateAccountRequest = GRPCUpdateAccountRequest()
        updateAccountRequest.accountID = id.rawValue
        updateAccountRequest.name = nameGoogleProtobuf
        updateAccountRequest.type = type.grpcType
        updateAccountRequest.favored = favoredGoogleProtobuf
        updateAccountRequest.excluded = excludedGoogleProtobuf
        updateAccountRequest.ownership = GRPCExactNumber(value: Decimal(ownership))
        return updateAccountRequest
    }
    
    private var nameGoogleProtobuf: Google_Protobuf_StringValue {
        return Google_Protobuf_StringValue(name)
    }
    private var favoredGoogleProtobuf: Google_Protobuf_BoolValue {
        return Google_Protobuf_BoolValue(isFavored)
    }
    private var excludedGoogleProtobuf: Google_Protobuf_BoolValue {
        return Google_Protobuf_BoolValue(isExcluded)
    }
}
