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
            let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
            if providersGroupedByAccessTypes.count == 1 {
                self = .credentialTypes(providers)
            } else {
                let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(ProviderAccessTypeGroup.init(providers:))
                self = .accessTypes(providersGroupedByAccessType)
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
                if providersGroupedByAccessTypes.count == 1 {
                    self = .credentialTypes(providers)
                } else {
                    let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(ProviderAccessTypeGroup.init(providers:))
                    self = .accessTypes(providersGroupedByAccessType)
                }
            } else {
                let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitutionIDs.values.map(FinancialInsititutionGroup.init(providers:))
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
