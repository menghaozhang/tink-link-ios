import Foundation

/// An object that accesses providers for a specific market and supports the grouping of providers.
public class ProviderContext {
    /// Attributes representing which providers a context should access.
    public struct Attributes: Hashable {
        public let capabilities: Provider.Capabilities
        public let kinds: Set<Provider.Kind>
        public let accessTypes: Set<Provider.AccessType>

        public init(capabilities: Provider.Capabilities, kinds: Set<Provider.Kind>, accessTypes: Set<Provider.AccessType>) {
            self.capabilities = capabilities
            self.kinds = kinds
            self.accessTypes = accessTypes
        }
    }

    private let market: Market
    private let authenticationManager: AuthenticationManager
    private let locale: Locale
    private let service: ProviderService

    /// Creates a context to access providers that matches the provided attributes.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    /// - Parameter attributes: Attributes describing which providers the context should access.
    public init(tinkLink: TinkLink = .shared) {
        self.market = tinkLink.client.market
        self.authenticationManager = tinkLink.authenticationManager
        self.service = tinkLink.client.providerService
        self.locale = tinkLink.client.locale
    }

    public func fetchProviders(attributes: Attributes, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable {
        let multiHandler = MultiHandler()

        let authCanceller = authenticationManager.authenticateIfNeeded(service: service, for: market, locale: locale) { [weak self, attributes, market] authenticationResult in
            guard let self = self, !multiHandler.isCancelled else { return }
            do {
                try authenticationResult.get()
                let fetchCanceller = self.service.providers(market: market, capabilities: attributes.capabilities, includeTestProviders: attributes.kinds.contains(.test)) { result in
                    do {
                        let fetchedProviders = try result.get()
                        let filteredProviders = fetchedProviders.filter { attributes.accessTypes.contains($0.accessType) && attributes.kinds.contains($0.kind) }
                        completion(.success(filteredProviders))
                    } catch {
                        completion(.failure(error))
                    }
                }
                multiHandler.add(fetchCanceller)
            } catch {
                completion(.failure(error))
            }
        }
        if let canceller = authCanceller {
            multiHandler.add(canceller)
        }

        return multiHandler
    }
}
