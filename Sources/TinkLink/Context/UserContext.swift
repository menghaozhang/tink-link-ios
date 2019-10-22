import Foundation

/// An object that you use to register for an access token that will be used in other TinkLink APIs.
public final class UserContext {
    private var userService: UserService
    private var retryCancellable: RetryCancellable?
    public private(set) var accessToken: AccessToken?

    /// Creates a context to register for an access token that will be used in other TinkLink APIs.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    public init(tinkLink: TinkLink = .shared) {
        self.userService = UserService(tinkLink: tinkLink)
    }

    /// Register for an access token for a specific market and locale.
    ///  - Note: If an access token has registered by this `UserContext` then completion will be triggered immediately.
    ///
    /// - Parameter market: Register a `Market` for authentication,  will use the default market if nothing is provided.
    /// - Parameter locale: Register a `Locale` for authentication,  will use the default locale in TinkLink if nothing is provided.
    public func authenticateIfNeeded(for market: Market = .defaultMarket, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable? {
        if let accessToken = accessToken {
            completion(.success(accessToken))
        } else if retryCancellable == nil {
            retryCancellable = userService.createAnonymous(market: market, locale: locale) { [weak self] result in
                guard let self = self else { return }
                do {
                    let accessToken = try result.get()
                    self.accessToken = accessToken
                    completion(.success((accessToken)))
                } catch {
                    completion(.failure(error))
                }
                self.retryCancellable = nil
            }
        }
        return retryCancellable
    }
}
