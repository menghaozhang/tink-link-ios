import Dispatch
internal class ProviderService {
    private var client: Client
    private var hasOnGoingProviderCall: Bool = false
    private var hasOnGoingMarketCall: Bool = false
    init(client: Client) {
        self.client = client
    }

    func providers(marketCode: String? = nil, completion: @escaping (Result<[Provider], Error>) -> Void) {
        if hasOnGoingProviderCall {
            return
        } else {
            hasOnGoingProviderCall = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasOnGoingProviderCall = false
            let providers: [Provider]
            if marketCode == "SE" {
                providers = [
                    Provider(name: "Avanza", financialInstitutionID: "Avanza", groupedName: "Avanza", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "SE"),
                    Provider(name: "SBAB BankID", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification], market: "SE"),
                    Provider(name: "SBAB Password", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "SE"),
                    Provider(name: "SEB BankID", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification], market: "SE"),
                    Provider(name: "SEB Password", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "SE"),
                    Provider(name: "SEB openbanking", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .openBanking, credentialType: .thirdPartyAuthentication, fields: [Provider.securityCodeFieldSpecification], market: "SE"),
                    Provider(name: "Nordea BankID", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification], market: "SE"),
                    Provider(name: "Nordea Password", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "SE"),
                    Provider(name: "Nordea Openbanking", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .openBanking, credentialType: .thirdPartyAuthentication, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "SE"),
                    Provider(name: "Nordea", financialInstitutionID: "Nordea Other", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.inputCodeFieldSpecification], market: "SE")
                ]
            } else {
                providers = [
                    Provider(name: "SBAB BankID", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification], market: "NO"),
                    Provider(name: "SBAB Password", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "NO"),
                    Provider(name: "SEB BankID", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification], market: "NO"),
                    Provider(name: "SEB Password", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "NO"),
                    Provider(name: "SEB openbanking", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .openBanking, credentialType: .thirdPartyAuthentication, fields: [Provider.securityCodeFieldSpecification], market: "NO"),
                    Provider(name: "Nordea BankID", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .mobileBankID, fields: [Provider.personalNumberFieldSpecification], market: "NO"),
                    Provider(name: "Nordea Password", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "NO"),
                    Provider(name: "Nordea Openbanking", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .openBanking, credentialType: .thirdPartyAuthentication, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification], market: "NO"),
                    Provider(name: "Nordea", financialInstitutionID: "Nordea Other", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.inputCodeFieldSpecification], market: "NO")
                ]
            }
            completion(.success(providers))
        }
    }
    
    func providerMarkets(completion: @escaping (Result<[String], Error>) -> Void) {
        if hasOnGoingMarketCall {
            return
        } else {
            hasOnGoingMarketCall = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasOnGoingMarketCall = false
            let markets = ["SE", "DK", "NO", "FI"]
            completion(.success(markets))
        }
    }
}
