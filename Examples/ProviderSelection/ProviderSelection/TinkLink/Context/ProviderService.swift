import Dispatch
internal class ProviderService {
    var client: Client
    private var hasOnGoingCall: Bool = false
    init(client: Client) {
        self.client = client
    }
    
    func providers(marketCode: String? = nil, completion: @escaping (Result<[Provider], Error>) -> Void) {
        if hasOnGoingCall {
            return
        } else {
            hasOnGoingCall = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasOnGoingCall = false
            let providers = [
                Provider(name: "Avanza", financialInstitutionID: "Avanza", groupedName: "Avanza", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
                Provider(name: "SBAB BankID", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification]),
                Provider(name: "SBAB Password", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
                Provider(name: "SEB BankID", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification]),
                Provider(name: "SEB Password", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
                Provider(name: "SEB openbanking", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .openBanking, credentialType: .thirdPartyAuthentication, fields: [Provider.securityCodeFieldSpecification]),
                Provider(name: "Nordea BankID", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification]),
                Provider(name: "Nordea Password", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
                Provider(name: "Nordea Openbanking", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .openBanking, credentialType: .thirdPartyAuthentication, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
                Provider(name: "Nordea", financialInstitutionID: "Nordea Other", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.inputCodeFieldSpecification])
            ]
            completion(.success(providers))
        }
    }
}
