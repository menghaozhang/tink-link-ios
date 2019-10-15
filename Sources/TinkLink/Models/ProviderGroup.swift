public enum ProviderAccessTypeGroup {
    case provider(Provider)
    case credentialTypes([Provider])

    init(providers: [Provider]) {
        precondition(!providers.isEmpty)
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

public enum FinancialInstitutionGroup {
    case provider(Provider)
    case credentialTypes([Provider])
    case accessTypes([ProviderAccessTypeGroup])

    init(providers: [Provider]) {
        precondition(!providers.isEmpty)
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
            if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
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

    public var financialInstitution: FinancialInstitution {
        return providers[0].financialInstitution
    }
}

public enum ProviderGroup {
    case provider(Provider)
    case credentialTypes([Provider])
    case accessTypes([ProviderAccessTypeGroup])
    case financialInstitutions([FinancialInstitutionGroup])

    init(providers: [Provider]) {
        precondition(!providers.isEmpty)
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            let providersGroupedByFinancialInstitutionIDs = Dictionary(grouping: providers, by: { $0.financialInstitution.id })
            if providersGroupedByFinancialInstitutionIDs.count == 1, let providers = providersGroupedByFinancialInstitutionIDs.values.first {
                let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                    self = .credentialTypes(providers)
                } else {
                    let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(ProviderAccessTypeGroup.init(providers:))
                    self = .accessTypes(providersGroupedByAccessType)
                }
            } else {
                let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitutionIDs.values.map(FinancialInstitutionGroup.init(providers:))
                self = .financialInstitutions(providersGroupedByFinancialInstitution)
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
        case .financialInstitutions(let providerGroupedByFinancialInstitutions):
            return providerGroupedByFinancialInstitutions.flatMap { $0.providers }
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
