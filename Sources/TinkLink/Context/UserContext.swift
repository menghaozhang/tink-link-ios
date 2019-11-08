import Foundation

/// An object that you use to create a user that will be used in other TinkLink APIs.
public final class UserContext {
    private let userService: UserService
    private var retryCancellable: RetryCancellable?

    /// Creates a context to register for an access token that will be used in other TinkLink APIs.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    public init(tinkLink: TinkLink = .shared) {
        self.userService = UserService(tinkLink: tinkLink)
    }

    /// Create a user for a specific market and locale.
    ///  - Note: If a user has been created by this `UserContext` already then the completion will be triggered immediately.
    ///
    /// - Parameter market: Register a `Market` for creating the user, will use the default market if nothing is provided.
    /// - Parameter locale: Register a `Locale` for creating the user, will use the default locale in TinkLink if nothing is provided.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func createUser(for market: Market, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        let retryCancellable = userService.createAnonymous(market: market, locale: locale) { result in
            do {
                let accessToken = try result.get()
                let user = User(accessToken: accessToken, market: market, locale: locale)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        return retryCancellable
    }
}
