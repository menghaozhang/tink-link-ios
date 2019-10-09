public enum ProviderAccessTypeGroup {
    case provider(Provider)
    case credentialTypes([Provider])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            self = .credentialTypes(providers)
        }
    }
    
    public var providers: [Provider] {
        switch self {
        case .credentialTypes(let providers):
            return providers
        case .provider(let provider):
            return [provider]
        }
    }
    
    public var accessType: Provider.AccessType {
        return providers[0].accessType
    }
}

public enum FinancialInsititutionGroup {
    case provider(Provider)
    case credentialTypes([Provider])
    case accessTypes([ProviderAccessTypeGroup])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            let providerGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
            let accessTypes = providerGroupedByAccessTypes.map { $0.key }
            if accessTypes.count == 1 {
                self = .credentialTypes(providers)
            } else {
                var providerGroupedByAccessType = [ProviderAccessTypeGroup]()
                accessTypes.forEach { accessType in
                    let providersWithSameAccessType = providers.filter({ $0.accessType == accessType })
                    providerGroupedByAccessType.append(ProviderAccessTypeGroup(providers: providersWithSameAccessType))
                }
                self = .accessTypes(providerGroupedByAccessType)
            }
        }
    }
    
    public var providers: [Provider] {
        switch self {
        case .accessTypes(let providerGroupByAccessTypes):
            return providerGroupByAccessTypes.flatMap { $0.providers }
        case .credentialTypes(let providers):
            return providers
        case .provider(let provider):
            return [provider]
        }
    }
    
    public var financialInsititutionName: String {
        return providers[0].financialInstitutionName
    }
}

public enum ProviderGroup {
    case provider(Provider)
    case credentialTypes([Provider])
    case accessTypes([ProviderAccessTypeGroup])
    case financialInsititutions([FinancialInsititutionGroup])
    
    init(providers: [Provider]) {
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            let providersGroupedByFinancialInstitutionIDs = Dictionary(grouping: providers, by: { $0.financialInstitutionID })
            if providersGroupedByFinancialInstitutionIDs.count == 1 {
                let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                let accessTypes = providersGroupedByAccessTypes.map { $0.key }
                if accessTypes.count == 1 {
                    self = .credentialTypes(providers)
                } else {
                    var providersGroupedByAccessType = [ProviderAccessTypeGroup]()
                    accessTypes.forEach { accessType in
                        let providersWithSameAccessType = providers.filter({ $0.accessType == accessType })
                        providersGroupedByAccessType.append(ProviderAccessTypeGroup(providers: providersWithSameAccessType))
                    }
                    self = .accessTypes(providersGroupedByAccessType)
                }
            } else {
                let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitutionIDs.map { (_, providers) in FinancialInsititutionGroup(providers: providers) }
                self = .financialInsititutions(providersGroupedByFinancialInstitution)
            }
        }
    }

    public static func makeGroups(providers: [Provider]) -> [ProviderGroup] {
        return Dictionary(grouping: providers, by: { $0.groupDisplayName })
            .sorted(by: { $0.key < $1.key })
            .map { ProviderGroup(providers: $0.value) }
    }
    
    public var providers: [Provider] {
        switch self {
        case .financialInsititutions(let providerGroupedByFinancialInsititutions):
            return providerGroupedByFinancialInsititutions.flatMap{ $0.providers }
        case .accessTypes(let providerGroupByAccessTypes):
            return providerGroupByAccessTypes.flatMap { $0.providers }
        case .credentialTypes(let providers):
            return providers
        case .provider(let provider):
            return [provider]
        }
    }
    
    public var displayName: String {
        return providers[0].groupDisplayName
    }
}
