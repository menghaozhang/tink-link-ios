struct Provider {
    let name: String
    let financialInstitutionID: String
    let groupedName: String
    let accessType: AccessType
    var credentialType: CredentialType
    
    enum AccessType: String {
        case reverseEngineering
        case openBanking
    }
    
    enum CredentialType: String {
        case bankID
        case password
        case thirdParty
    }
}

enum ProviderGroupedByAccessType {
    case singleProvider(Provider)
    case multipleCredentialTypes([Provider])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .singleProvider(provider)
        } else {
            self = .multipleCredentialTypes(providers)
        }
    }
    
    var providers: [Provider] {
        switch self {
        case .multipleCredentialTypes(let providers):
            return providers
        case .singleProvider(let provider):
            return [provider]
        }
    }
    
    var accessType: String? {
        return providers.first?.accessType.rawValue
    }
}

enum ProviderGroupedByFinancialInsititution {
    case singleProvider(Provider)
    case multipleCredentialTypes([Provider])
    case multupleAccessTypes([ProviderGroupedByAccessType])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .singleProvider(provider)
        } else {
            let providerGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
            let accessTypes = providerGroupedByAccessTypes.map { $0.key }
            if accessTypes.count == 1 {
                self = .multipleCredentialTypes(providers)
            } else {
                var providerGroupedByAccessType = [ProviderGroupedByAccessType]()
                accessTypes.forEach { accessType in
                    let providersWithSameAccessType = providers.filter({ $0.accessType == accessType })
                    providerGroupedByAccessType.append(ProviderGroupedByAccessType(providers: providersWithSameAccessType))
                }
                self = .multupleAccessTypes(providerGroupedByAccessType)
            }
        }
    }
    
    var providers: [Provider] {
        switch self {
        case .multupleAccessTypes(let providerGroupByAccessTypes):
            return providerGroupByAccessTypes.flatMap { $0.providers }
        case .multipleCredentialTypes(let providers):
            return providers
        case .singleProvider(let provider):
            return [provider]
        }
    }
    
    var financialInsititutionID: String? {
        return providers.first?.financialInstitutionID
    }
}

enum ProviderGroupedByGroupedName {
    case singleProvider(Provider)
    case multipleCredentialTypes([Provider])
    case multupleAccessTypes([ProviderGroupedByAccessType])
    case financialInsititutions([ProviderGroupedByFinancialInsititution])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .singleProvider(provider)
        } else {
            let providerGroupedByFinancialInstitutions = Dictionary(grouping: providers, by: { $0.financialInstitutionID })
            let financialInstitutions = providerGroupedByFinancialInstitutions.map { $0.key }
            if financialInstitutions.count == 1 {
                let providerGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                let accessTypes = providerGroupedByAccessTypes.map { $0.key }
                if accessTypes.count == 1 {
                    self = .multipleCredentialTypes(providers)
                } else {
                    var providerGroupedByAccessType = [ProviderGroupedByAccessType]()
                    accessTypes.forEach { accessType in
                        let providersWithSameAccessType = providers.filter({ $0.accessType == accessType })
                        providerGroupedByAccessType.append(ProviderGroupedByAccessType(providers: providersWithSameAccessType))
                    }
                    self = .multupleAccessTypes(providerGroupedByAccessType)
                }
            } else {
                var providerGroupedByFinancialInstitution = [ProviderGroupedByFinancialInsititution]()
                financialInstitutions.forEach { financialInstitution in
                    let providersWithSameFinancialInstitutions = providers.filter({ $0.financialInstitutionID == financialInstitution })
                    providerGroupedByFinancialInstitution.append(ProviderGroupedByFinancialInsititution(providers: providersWithSameFinancialInstitutions))
                }
                self = .financialInsititutions(providerGroupedByFinancialInstitution)
            }
        }
    }
    
    var providers: [Provider] {
        switch self {
        case .financialInsititutions(let providerGroupedByFinancialInsititutions):
            return providerGroupedByFinancialInsititutions.flatMap{ $0.providers }
        case .multupleAccessTypes(let providerGroupByAccessTypes):
            return providerGroupByAccessTypes.flatMap { $0.providers }
        case .multipleCredentialTypes(let providers):
            return providers
        case .singleProvider(let provider):
            return [provider]
        }
    }
    
    var groupedName: String? {
        return providers.first?.groupedName
    }
}
