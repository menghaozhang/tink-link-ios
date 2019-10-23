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

        public static let `default` = Attributes(capabilities: .all, kinds: .excludingTest, accessTypes: .all)
    }

    private let tinkLink: TinkLink
    private let userCreationStrategy: UserCreationStrategy
    private let service: ProviderService
    private let market: Market
    private let locale: Locale

    /// Creates a context to access providers that matches the provided attributes.
    /// 
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    /// - Parameter user: `User` that will be used for fetching providers with the Tink API.
    public convenience init(tinkLink: TinkLink = .shared, user: User) {
        self.init(tinkLink: tinkLink, userCreationStrategy: .existing(user))
    }

    /// Creates a context to access providers that matches the provided attributes.
    ///
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    /// - Parameter userCreationStrategy: The strategy for creating users. Defaults to automatically creating a anonymous user.
    public init(tinkLink: TinkLink = .shared, userCreationStrategy: UserCreationStrategy = .automaticAnonymous) {
        self.tinkLink = tinkLink
        self.userCreationStrategy = userCreationStrategy
        self.service = ProviderService(tinkLink: tinkLink)
        self.market = tinkLink.client.market
        self.locale = tinkLink.client.locale
    }

    /// Fetches providers matching the provided attributes.
    ///
    /// - Parameter attributes: Attributes for providers to fetch
    /// - Parameter completion: A result representing either a list of providers or an error.
    public func fetchProviders(attributes: Attributes = .default, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        let authenticationCanceller = tinkLink.authenticateIfNeeded(with: userCreationStrategy) { [service, market] (userResult) in
            do {
                let user = try userResult.get()
                service.accessToken = user.accessToken
                let fetchCancellable = service.providers(market: market, capabilities: attributes.capabilities, includeTestProviders: attributes.kinds.contains(.test)) { result in
                    do {
                        let fetchedProviders = try result.get()
                        let filteredProviders = fetchedProviders.filter { attributes.accessTypes.contains($0.accessType) && attributes.kinds.contains($0.kind) }
                        completion(.success(filteredProviders))
//                        let error = NSError(domain: CocoaError.errorDomain, code: CocoaError.coderInvalidValue.rawValue, userInfo: nil)
//                        completion(.failure(error))
                    } catch {
                        completion(.failure(error))
                    }
                }
                return fetchCancellable
            } catch {
                completion(.failure(error))
                return nil
            }
        }

        return authenticationCanceller
    }
}
