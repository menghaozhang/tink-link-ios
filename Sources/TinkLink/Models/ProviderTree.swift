// This type represents a tree structure of providers.
///
/// This tree eventually leads to a leaf of type `Provider` that contains more detailed data about a provider.
public struct ProviderTree {
    public let financialInstitutionGroups: [FinancialInstitutionGroup]

    public init(providers: [Provider]) {
        self.financialInstitutionGroups = Dictionary(grouping: providers, by: { $0.groupDisplayName.isEmpty ? $0.financialInstitution.id.value : $0.groupDisplayName })
            .sorted(by: { $0.key < $1.key })
            .map { FinancialInstitutionGroup(providers: $0.value) }
    }

    public struct CredentialKindGroup {
        public let provider: Provider

        public var credentialKind: Credential.Kind { provider.credentialKind }

        public var displayDescription: String { provider.displayDescription.isEmpty ? provider.credentialKind.description : provider.displayDescription }
    }

    public enum AccessTypeGroup {
        case provider(Provider)
        case credentialKinds([CredentialKindGroup])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                self = .credentialKinds(providers.map(CredentialKindGroup.init(provider:)))
            }
        }

        public var providers: [Provider] {
            switch self {
            case .credentialKinds(let groups):
                return groups.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        private var firstProvider: Provider {
            switch self {
            case .credentialKinds(let groups):
                return groups[0].provider
            case .provider(let provider):
                return provider
            }
        }

        public var accessType: Provider.AccessType { firstProvider.accessType }
    }

    public enum FinancialInstitution {
        case provider(Provider)
        case credentialKinds([CredentialKindGroup])
        case accessTypes([AccessTypeGroup])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                    self = .credentialKinds(providers.map(CredentialKindGroup.init(provider:)))
                } else {
                    let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(AccessTypeGroup.init(providers:))
                    self = .accessTypes(providersGroupedByAccessType)
                }
            }
        }

        public var providers: [Provider] {
            switch self {
            case .accessTypes(let providerGroupByAccessTypes):
                return providerGroupByAccessTypes.flatMap { $0.providers }
            case .credentialKinds(let groups):
                return groups.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        private var firstProvider: Provider {
            switch self {
            case .accessTypes(let accessTypeGroups):
                switch accessTypeGroups[0] {
                case .credentialKinds(let groups):
                    return groups[0].provider
                case .provider(let provider):
                    return provider
                }
            case .credentialKinds(let groups):
                return groups[0].provider
            case .provider(let provider):
                return provider
            }
        }

        public var financialInstitution: Provider.FinancialInstitution { firstProvider.financialInstitution }
    }

    public enum FinancialInstitutionGroup {
        case provider(Provider)
        case credentialKinds([CredentialKindGroup])
        case accessTypes([AccessTypeGroup])
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
                        self = .credentialKinds(providers.map(CredentialKindGroup.init(provider:)))
                    } else {
                        let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(AccessTypeGroup.init(providers:))
                        self = .accessTypes(providersGroupedByAccessType)
                    }
                } else {
                    let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitution.values.map(FinancialInstitution.init(providers:))
                    self = .financialInstitutions(providersGroupedByFinancialInstitution)
                }
            }
        }

        public var providers: [Provider] {
            switch self {
            case .financialInstitutions(let providerGroupedByFinancialInstitutions):
                return providerGroupedByFinancialInstitutions.flatMap { $0.providers }
            case .accessTypes(let providerGroupByAccessTypes):
                return providerGroupByAccessTypes.flatMap { $0.providers }
            case .credentialKinds(let groups):
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
                    case .credentialKinds(let groups):
                        return groups[0].provider
                    case .provider(let provider):
                        return provider
                    }
                case .credentialKinds(let groups):
                    return groups[0].provider
                case .provider(let provider):
                    return provider
                }
            case .accessTypes(let providerAccessTypeGroups):
                switch providerAccessTypeGroups[0] {
                case .credentialKinds(let groups):
                    return groups[0].provider
                case .provider(let provider):
                    return provider
                }
            case .credentialKinds(let groups):
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
}
