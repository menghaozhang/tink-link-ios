// This type represents a tree structure of providers.
///
/// This tree eventually leads to a leaf of type `Provider` that contains more detailed data about a provider.
public struct ProviderTree {
    public let financialInstitutionGroups: [FinancialInstitutionGroupNode]

    public init(providers: [Provider]) {
        self.financialInstitutionGroups = Dictionary(grouping: providers, by: { $0.groupDisplayName.isEmpty ? $0.financialInstitution.id.value : $0.groupDisplayName })
            .sorted(by: { $0.key < $1.key })
            .map { FinancialInstitutionGroupNode(providers: $0.value) }
    }

    /// A parent node of the tree structure, with a `Provider` as it's leaf node.
    public struct CredentialKindNode {
        public let provider: Provider

        public var credentialKind: Credential.Kind { provider.credentialKind }

        public var displayDescription: String { provider.displayDescription.isEmpty ? provider.credentialKind.description : provider.displayDescription }
    }

    /// A parent node of the tree structure, with a list of either `CredentialKindNode` children or a single `Provider`.
    public enum AccessTypeNode {
        case provider(Provider)
        case credentialKinds([CredentialKindNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                self = .credentialKinds(providers.map(CredentialKindNode.init(provider:)))
            }
        }

        public var providers: [Provider] {
            switch self {
            case .credentialKinds(let nodes):
                return nodes.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        private var firstProvider: Provider {
            switch self {
            case .credentialKinds(let nodes):
                return nodes[0].provider
            case .provider(let provider):
                return provider
            }
        }

        public var accessType: Provider.AccessType { firstProvider.accessType }
    }

    /// A parent node of the tree structure, with a list of either `AccessTypeNode`, `CredentialKindNode` children or a single `Provider`.
    public enum FinancialInstitutionNode {
        case provider(Provider)
        case credentialKinds([CredentialKindNode])
        case accessTypes([AccessTypeNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                    self = .credentialKinds(providers.map(CredentialKindNode.init(provider:)))
                } else {
                    let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(AccessTypeNode.init(providers:))
                    self = .accessTypes(providersGroupedByAccessType)
                }
            }
        }

        public var providers: [Provider] {
            switch self {
            case .accessTypes(let nodes):
                return nodes.flatMap { $0.providers }
            case .credentialKinds(let nodes):
                return nodes.map { $0.provider }
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

    /// A parent node of the tree structure, with a list of either `FinancialInstitutionNode`, `AccessTypeNode`, `CredentialKindNode` children or a single `Provider`.
    public enum FinancialInstitutionGroupNode {
        case provider(Provider)
        case credentialKinds([CredentialKindNode])
        case accessTypes([AccessTypeNode])
        case financialInstitutions([FinancialInstitutionNode])

        init(providers: [Provider]) {
            precondition(!providers.isEmpty)
            if providers.count == 1, let provider = providers.first {
                self = .provider(provider)
            } else {
                let providersGroupedByFinancialInstitution = Dictionary(grouping: providers, by: { $0.financialInstitution })
                if providersGroupedByFinancialInstitution.count == 1, let providers = providersGroupedByFinancialInstitution.values.first {
                    let providersGroupedByAccessTypes = Dictionary(grouping: providers, by: { $0.accessType })
                    if providersGroupedByAccessTypes.count == 1, let providers = providersGroupedByAccessTypes.values.first {
                        self = .credentialKinds(providers.map(CredentialKindNode.init(provider:)))
                    } else {
                        let providersGroupedByAccessType = providersGroupedByAccessTypes.values.map(AccessTypeNode.init(providers:))
                        self = .accessTypes(providersGroupedByAccessType)
                    }
                } else {
                    let providersGroupedByFinancialInstitution = providersGroupedByFinancialInstitution.values.map(FinancialInstitutionNode.init(providers:))
                    self = .financialInstitutions(providersGroupedByFinancialInstitution)
                }
            }
        }

        public var providers: [Provider] {
            switch self {
            case .financialInstitutions(let nodes):
                return nodes.flatMap { $0.providers }
            case .accessTypes(let nodes):
                return nodes.flatMap { $0.providers }
            case .credentialKinds(let nodes):
                return nodes.map { $0.provider }
            case .provider(let provider):
                return [provider]
            }
        }

        private var firstProvider: Provider {
            switch self {
            case .financialInstitutions(let nodes):
                switch nodes[0] {
                case .accessTypes(let nodes):
                    switch nodes[0] {
                    case .credentialKinds(let nodes):
                        return nodes[0].provider
                    case .provider(let provider):
                        return provider
                    }
                case .credentialKinds(let nodes):
                    return nodes[0].provider
                case .provider(let provider):
                    return provider
                }
            case .accessTypes(let nodes):
                switch nodes[0] {
                case .credentialKinds(let nodes):
                    return nodes[0].provider
                case .provider(let provider):
                    return provider
                }
            case .credentialKinds(let nodes):
                return nodes[0].provider
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
