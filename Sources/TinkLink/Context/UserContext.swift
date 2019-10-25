import Foundation

/// An object that you use to create a user that will be used in other TinkLink APIs.
public final class UserContext {
    private let userService: UserService
    private var retryCancellable: RetryCancellable?
    private var multiRetryCancellables = MultiHandler()
    private var group = DispatchGroup()
    private var canLeaveDispatchGroup = false
    /// The user associated with this `UserContext` if there is one.
    public private(set) var user: User?
    private var error: Error?

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
    public func createUser(for market: Market = .defaultMarket, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> Void) -> RetryCancellable? {
        createUserIfNeeded(for: market, locale: locale) { result -> RetryCancellable? in
            completion(result)
            return nil
        }
    }

    func createUserIfNeeded(for market: Market = .defaultMarket, locale: Locale = TinkLink.defaultLocale, completion: @escaping (Result<User, Error>) -> RetryCancellable?) -> RetryCancellable? {
        if let user = user {
            return completion(.success(user))
        } else if retryCancellable == nil {
            group.enter()
            canLeaveDispatchGroup = true
            retryCancellable = userService.createAnonymous(market: market, locale: locale) { [weak self] result in
                guard let self = self else { return }
                do {
                    let accessToken = try result.get()
                    let user = User(accessToken: accessToken)
                    self.user = user
                    self.retryCancellable = completion(.success(user))
                } catch {
                    self.error = error
                    self.retryCancellable = completion(.failure(error))
                }
                if self.canLeaveDispatchGroup {
                    self.canLeaveDispatchGroup = false
                    self.group.leave()
                }
            }
            return retryCancellable
        } else {
            group.notify(queue: .main, execute: { [weak self] in
                guard let self = self else { return }
                if let user = self.user {
                    self.multiRetryCancellables.add(completion(.success(user)))
                } else {
                    let retryCancellable = self.createUserIfNeeded(for: market, locale: locale, completion: completion)
                    self.multiRetryCancellables.add(retryCancellable)
                }
            })
            return multiRetryCancellables
        }
    }
}
