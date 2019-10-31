import Foundation
#if os(iOS)
    import UIKit
#endif

/// The `TinkLink` class encapsulates a connection to the Tink API.
///
/// By default a shared `TinkLink` instance will be used, but you can also create your own
/// instance and use that instead. This allows you to use multiple `TinkLink` instances at the
/// same time.
public class TinkLink {
    static var _shared: TinkLink?

    /// The shared `TinkLink` instance.
    ///
    /// Note: You need to configure the shared instance by calling `TinkLink.configure(with:)`
    /// before accessing the shared instance. Not doing so will cause a run-time error.
    public static var shared: TinkLink {
        guard let shared = _shared else {
            fatalError("Configure Tink Link by calling `TinkLink.configure(with:)` before accessing the shared instance")
        }
        return shared
    }

    /// The current configuration.
    public let configuration: Configuration

    private(set) lazy var client = Client(configuration: configuration)

    private init() {
        do {
            self.configuration = try Configuration(processInfo: .processInfo)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Create a TinkLink instance with a custom configuration.
    /// - Parameters:
    ///   - configuration: The configuration to be used.
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// Configure shared instance with configration description.
    ///
    /// Here's how you could configure TinkLink with a `TinkLink.Configuration`.
    ///
    ///     let configuration = Configuration(clientID: "<#clientID#>", redirectURI: <#URL#>, market: "<#SE#>", locale: .current)
    ///     TinkLink.configure(with: configuration)
    ///
    /// - Parameters:
    ///   - configuration: The configuration to be used for the shared instance.
    public static func configure(with configuration: TinkLink.Configuration) {
        _shared = TinkLink(configuration: configuration)
    }

    private var thirdPartyCallbackCanceller: Cancellable?

    private lazy var automaticAnonymousUserContext = UserContext(tinkLink: self)

    func authenticateIfNeeded(with userCreationStrategy: UserCreationStrategy, completion: @escaping (Result<User, Error>) -> RetryCancellable?) -> RetryCancellable? {
        switch userCreationStrategy {
        case .automaticAnonymous:
            let userCanceller = automaticAnonymousUserContext.createUserIfNeeded(for: configuration.market, locale: configuration.locale, completion: completion)
            return userCanceller
        case .existing(let user):
            return completion(.success(user))
        }
    }

    @available(iOS 9.0, *)
    public func open(_ url: URL, user: User, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        return open(url, userCreationStrategy: .existing(user), completion: completion)
    }

    public func open(_ url: URL, userCreationStrategy: UserCreationStrategy = .automaticAnonymous, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme == configuration.redirectURI.scheme
        else { return false }

        var parameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        let stateParameterName = "state"
        guard let state = parameters.removeValue(forKey: stateParameterName) else { return false }

        authenticateIfNeeded(with: userCreationStrategy) { userResult in
            do {
                let user = try userResult.get()
                let credentialService = CredentialService(tinkLink: self, accessToken: user.accessToken)
                let thirdPartyCallbackCanceller = credentialService.thirdPartyCallback(
                    state: state,
                    parameters: parameters,
                    completion: completion ?? { _ in }
                )
                self.thirdPartyCallbackCanceller = thirdPartyCallbackCanceller
                return thirdPartyCallbackCanceller
            } catch {
                completion?(.failure(error))
                return nil
            }
        }

        return true
    }
}
