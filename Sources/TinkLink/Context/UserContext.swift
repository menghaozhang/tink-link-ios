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
    ///
    /// - Parameter market: Register a `Market` for creating the user, will use the default market if nothing is provided.
    /// - Parameter locale: Register a `Locale` for creating the user, will use the default locale in TinkLink if nothing is provided.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func createUser(for market: Market, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        return userService.createAnonymous(market: market, locale: locale) { result in
            do {
                let accessToken = try result.get()
                let user = User(accessToken: accessToken, market: market, locale: locale)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Authenticate a permanent user with authorization code.
    ///
    /// - Parameter authorizationCode: Authenticate with a `AuthorizationCode` that delegated from Tink to exchanged for a user object.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func authenticateUser(authorizationCode: AuthorizationCode, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        return userService.authenticate(code: authorizationCode, completion: { [weak self] result in
            do {
                let authenticateResponse = try result.get()
                let accessToken = authenticateResponse.accessToken
                self?.retryCancellable = self?.userService.getUserProfile { result in
                    do {
                        let (market, locale) = try result.get()
                        let user = User(accessToken: accessToken, market: market, locale: locale)
                        completion(.success(user))
                    } catch {
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        })
    }

    /// Authenticate a permanent user with accessToken.
    ///
    /// - Parameter accessToken: Authenticate with an accessToken `String` that generated for the permanent user.
    /// - Parameter completion: A result representing either a user info object or an error.
    @discardableResult
    public func authenticateUser(accessToken: String, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        let accessToken = AccessToken(accessToken)
        return userService.getUserProfile { result in
            do {
                let (market, locale) = try result.get()
                let user = User(accessToken: accessToken, market: market, locale: locale)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
