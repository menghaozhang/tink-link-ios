class ProviderContext {
    let client: Client
    init(client: Client) {
        self.client = client
        providers = [
            Provider(name: "Avanza", financialInstitutionID: "Avanza", groupedName: "Avanza", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "SBAB BankID", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .bankID, fields: [Provider.personalNumberFieldSpecification]),
            Provider(name: "SBAB Password", financialInstitutionID: "SBAB", groupedName: "SBAB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "SEB BankID", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .bankID, fields: [Provider.personalNumberFieldSpecification]),
            Provider(name: "SEB Password", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "SEB openbanking", financialInstitutionID: "SEB", groupedName: "SEB", accessType: .openBanking, credentialType: .thirdParty, fields: [Provider.securityCodeFieldSpecification]),
            Provider(name: "Nordea BankID", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .bankID, fields: [Provider.personalNumberFieldSpecification]),
            Provider(name: "Nordea Password", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "Nordea Openbanking", financialInstitutionID: "Nordea", groupedName: "Nordea", accessType: .openBanking, credentialType: .thirdParty, fields: [Provider.personalNumberFieldSpecification, Provider.passwordFieldSpecification]),
            Provider(name: "Nordea", financialInstitutionID: "Nordea Other", groupedName: "Nordea", accessType: .reverseEngineering, credentialType: .password, fields: [Provider.inputCodeFieldSpecification])
        ]
    }
    var providers: [Provider] {
        didSet {
            delegate?.providersDidChange(self)
        }
    }
    lazy var providerGroupsByGroupedName: [ProviderGroupedByGroupedName] = {
        return _providerGroupsByGroupedName
    }()
    weak var delegate: ProviderContextDelegate?
    
    private lazy var _providerGroupsByGroupedName: [ProviderGroupedByGroupedName] = {
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupedName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroupsByGroupedNames = [ProviderGroupedByGroupedName]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupedName == groupName })
            providerGroupsByGroupedNames.append(ProviderGroupedByGroupedName(providers: providersWithSameGroupedName))
            
        }
        return providerGroupsByGroupedNames.sorted(by: { $0.providers.count < $1.providers.count })
    }()
}

protocol ProviderContextDelegate: AnyObject {
    func providersDidChange(_ context: ProviderContext)
}
