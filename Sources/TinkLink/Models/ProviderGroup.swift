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

    private var firstProvider: Provider {
        switch self {
        case .credentialTypes(let providers):
            return providers[0]
        case .provider(let provider):
            return provider
        }
    }

    public var accessType: Provider.AccessType { firstProvider.accessType }
}

public enum FinancialInstitution {
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

    private var firstProvider: Provider {
        switch self {
        case .accessTypes(let accessTypeGroups):
            switch accessTypeGroups[0] {
            case .credentialTypes(let providers):
                return providers[0]
            case .provider(let provider):
                return provider
            }
        case .credentialTypes(let providers):
            return providers[0]
        case .provider(let provider):
            return provider
        }
    }

    public var financialInstitution: Provider.FinancialInstitution { firstProvider.financialInstitution }
}

public enum ProviderGroup {
    case provider(Provider)
    case credentialTypes([Provider])
    case accessTypes([ProviderAccessTypeGroup])
    case financialInstitutions([FinancialInstitution])

    init(providers: [Provider]) {
        precondition(!providers.isEmpty)
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            let providersGroupedByFinancialInstitution = Dictionary(grouping: providers, by: { $0.financialInstitution })
            if providersGroupedByFinancialInstitution.count == 1, let providers = providersGroupedByFinancialInstitution.values.first {
                let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                    self = .credentialTypes(providers)
                } else {
                    let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(ProviderAccessTypeGroup.init(providers:))
                    self = .accessTypes(providersGroupedByAccessType)
                }
            } else {
                let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitution.values.map(FinancialInstitution.init(providers:))
                self = .financialInstitutions(providersGroupedByFinancialInstitution)
            }
        }
    }

    public static func makeGroups(providers: [Provider]) -> [ProviderGroup] {
        return Dictionary(grouping: providers, by: { $0.groupDisplayName.isEmpty ? $0.financialInstitution.id.value : $0.groupDisplayName })
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

    private var firstProvider: Provider {
        switch self {
        case .financialInstitutions(let financialInstitutionGroups):
            switch financialInstitutionGroups[0] {
            case .accessTypes(let providerAccessTypeGroups):
                switch providerAccessTypeGroups[0] {
                case .credentialTypes(let providers):
                    return providers[0]
                case .provider(let provider):
                    return provider
                }
            case .credentialTypes(let providers):
                return providers[0]
            case .provider(let provider):
                return provider
            }
        case .accessTypes(let providerAccessTypeGroups):
            switch providerAccessTypeGroups[0] {
            case .credentialTypes(let providers):
                return providers[0]
            case .provider(let provider):
                return provider
            }
        case .credentialTypes(let providers):
            return providers[0]
        case .provider(let provider):
            return provider
        }
    }

    public var displayName: String {
        if firstProvider.groupDisplayName.isEmpty {
            return firstProvider.financialInstitution.name
        } else {
            return firstProvider.groupDisplayName
        }
    }
}
