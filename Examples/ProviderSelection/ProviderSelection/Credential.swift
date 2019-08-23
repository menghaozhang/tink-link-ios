import Foundation
// Mocked Credential model
struct Credential {
    var id: String
    var type: `Type`
    var status: Status
    var providerName: String
    var sessionExpiryDate: Date?
    var supplementalInformationFields: [Provider.FieldSpecification] = []
    var fields: [String: String]
    
    enum `Type`: String {
        case unknown
        case password
        case mobileBankID
        case keyfob
        case fraud
        case thirdPartyAuthentication
    }
    
    enum Status {
        case unknown
        case created
        case authenticating
        case updating
        case updated
        case temporaryError
        case authenticationError
        case permanentError
        case awaitingMobileBankIDAuthentication
        case awaitingSupplementalInformation
        case awaitingThirdPartyAppAuthentication
        case disabled
        case sessionExpired
    }
}
