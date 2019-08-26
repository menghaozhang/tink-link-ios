import Foundation
// Mocked Credential model
struct UpdatedtableCredentialFields {
    let id: String
    var supplementalInformationFields: [Provider.FieldSpecification]
}

extension UpdatedtableCredentialFields {
    init(credential: Credential) {
        id = credential.id
        supplementalInformationFields = credential.supplementalInformationFields
    }
}

struct Credential {
    let id: String
    let type: `Type`
    var status: Status
    let providerName: String
    let sessionExpiryDate: Date?
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
