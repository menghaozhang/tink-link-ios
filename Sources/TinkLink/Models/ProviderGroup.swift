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
    
    public var accessType: String? {
        return providers.first?.accessType.description
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
    
    public var financialInsititutionName: String? {
        return providers.first?.financialInstitutionName
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
            let providerGroupedByFinancialInstitutions = Dictionary(grouping: providers, by: { $0.financialInstitutionID })
            let financialInstitutions = providerGroupedByFinancialInstitutions.map { $0.key }
            if financialInstitutions.count == 1 {
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
            } else {
                var providerGroupedByFinancialInstitution = [FinancialInsititutionGroup]()
                financialInstitutions.forEach { financialInstitution in
                    let providersWithSameFinancialInstitutions = providers.filter({ $0.financialInstitutionID == financialInstitution })
                    providerGroupedByFinancialInstitution.append(FinancialInsititutionGroup(providers: providersWithSameFinancialInstitutions))
                }
                self = .financialInsititutions(providerGroupedByFinancialInstitution)
            }
        }
    }

    public static func makeGroups(providers: [Provider]) -> [ProviderGroup] {
        if providers.isEmpty { return [] }
        let providerGroupedByGroupedName = Dictionary(grouping: providers, by: { $0.groupDisplayName })
        let groupedNames = providerGroupedByGroupedName.map { $0.key }
        var providerGroups = [ProviderGroup]()
        groupedNames.forEach { groupName in
            let providersWithSameGroupedName = providers.filter({ $0.groupDisplayName == groupName })
            providerGroups.append(ProviderGroup(providers: providersWithSameGroupedName))
        }
        return providerGroups.sorted(by: { $0.groupedDisplayName ?? "" < $1.groupedDisplayName ?? "" })
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
    
    public var groupedDisplayName: String? {
        return providers.first?.groupDisplayName
    }
}
