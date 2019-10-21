public struct CredentialKindGroup {
    public let provider: Provider

    public var credentialKind: Credential.Kind { provider.credentialKind }

    public var displayDescription: String { provider.displayDescription.isEmpty ? provider.credentialKind.description : provider.displayDescription }
}

public enum ProviderAccessTypeGroup {
    case provider(Provider)
    case credentialTypes([CredentialKindGroup])

    init(providers: [Provider]) {
        precondition(!providers.isEmpty)
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            self = .credentialTypes(providers.map(CredentialKindGroup.init(provider:)))
        }
    }

    public var providers: [Provider] {
        switch self {
        case .credentialTypes(let groups):
            return groups.map { $0.provider }
        case .provider(let provider):
            return [provider]
        }
    }

    private var firstProvider: Provider {
        switch self {
        case .credentialTypes(let groups):
            return groups[0].provider
        case .provider(let provider):
            return provider
        }
    }

    public var accessType: Provider.AccessType { firstProvider.accessType }
}

public enum FinancialInstitution {
    case provider(Provider)
    case credentialTypes([CredentialKindGroup])
    case accessTypes([ProviderAccessTypeGroup])

    init(providers: [Provider]) {
        precondition(!providers.isEmpty)
        if providers.count == 1, let provider = providers.first {
            self = .provider(provider)
        } else {
            let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
            if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                self = .credentialTypes(providers.map(CredentialKindGroup.init(provider:)))
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
        case .credentialTypes(let groups):
            return groups.map { $0.provider }
        case .provider(let provider):
            return [provider]
        }
    }

    private var firstProvider: Provider {
        switch self {
        case .accessTypes(let accessTypeGroups):
            switch accessTypeGroups[0] {
            case .credentialTypes(let groups):
                return groups[0].provider
            case .provider(let provider):
                return provider
            }
        case .credentialTypes(let providers):
            return providers[0].provider
        case .provider(let provider):
            return provider
        }
    }

    public var financialInstitution: Provider.FinancialInstitution { firstProvider.financialInstitution }
}

public enum FinancialInstitutionGroup {
    case provider(Provider)
    case credentialTypes([CredentialKindGroup])
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
                    self = .credentialTypes(providers.map(CredentialKindGroup.init(provider:)))
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

    public static func makeGroups(providers: [Provider]) -> [FinancialInstitutionGroup] {
        return Dictionary(grouping: providers, by: { $0.groupDisplayName.isEmpty ? $0.financialInstitution.id.value : $0.groupDisplayName })
            .sorted(by: { $0.key < $1.key })
            .map { FinancialInstitutionGroup(providers: $0.value) }
    }

    public var providers: [Provider] {
        switch self {
        case .financialInstitutions(let providerGroupedByFinancialInstitutions):
            return providerGroupedByFinancialInstitutions.flatMap { $0.providers }
        case .accessTypes(let providerGroupByAccessTypes):
            return providerGroupByAccessTypes.flatMap { $0.providers }
        case .credentialTypes(let groups):
            return groups.map { $0.provider }
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
                case .credentialTypes(let groups):
                    return groups[0].provider
                case .provider(let provider):
                    return provider
                }
            case .credentialTypes(let providers):
                return providers[0].provider
            case .provider(let provider):
                return provider
            }
        case .accessTypes(let providerAccessTypeGroups):
            switch providerAccessTypeGroups[0] {
            case .credentialTypes(let groups):
                return groups[0].provider
            case .provider(let provider):
                return provider
            }
        case .credentialTypes(let groups):
            return groups[0].provider
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
