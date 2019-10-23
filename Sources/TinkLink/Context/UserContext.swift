import Foundation

/// An object that you use to create a user that will be used in other TinkLink APIs.
public final class UserContext {
    private var userService: UserService
    private var retryCancellable: RetryCancellable?
    public private(set) var user: User?

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
    public func createUserIfNeeded(for market: Market = .defaultMarket, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> RetryCancellable?) -> RetryCancellable? {
        if let user = user {
            return completion(.success(user))
        } else if retryCancellable == nil {
            retryCancellable = userService.createAnonymous(market: market, locale: locale) { [weak self] result in
                guard let self = self else { return }
                do {
                    let accessToken = try result.get()
                    let user = User(accessToken: accessToken)
                    self.user = user
                    self.retryCancellable = completion(.success(user))
                } catch {
                    self.retryCancellable = completion(.failure(error))
                }
            }
        }
        return retryCancellable
    }
}
