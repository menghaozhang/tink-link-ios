import Foundation
#if os(iOS)
import UIKit
#endif

public class TinkLink {
    static var _shared: TinkLink?

    public static var shared: TinkLink {
        guard let shared = _shared else {
            fatalError("Configure Tink Link by calling `TinkLink.configure()` before accessing the shared instance")
        }
        return shared
    }

    /// The current configuration.
    public let configuration: Configuration

    private(set) lazy var client = Client(configuration: configuration)

    lazy var authenticationManager = AuthenticationManager(tinkLink: self)

    private init() {
        do {
            self.configuration = try Configuration(processInfo: .processInfo)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Create a TinkLink instance with a custom configuration.
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
    public static func configure(with configuration: TinkLink.Configuration) {
        _shared = TinkLink(configuration: configuration)
    }

    /// Creates an authorization code with the requested scopes for the current user
    ///
    /// Once you have received the authorization code, you can exchange it for an access token on your backend and use the access token to access the user's data. Exchanging the authorization code for an access token requires the use of the client secret associated with your client identifier.
    ///
    /// - Parameter scope: A TinkLinkScope list of OAuth scopes to be requested.
    ///                    The Scope array should never be empty.
    /// - Parameter completion: The block to execute when the authorization is complete.
    /// - Parameter result: Represents either an authorization code if authorization was successful or an error if authorization failed.
    @discardableResult
    public func authorize(scope: TinkLink.Scope, completion: @escaping (_ result: Result<AuthorizationCode, Error>) -> Void) -> Cancellable? {
        return client.authenticationService.authorize(redirectURI: configuration.redirectURI, scope: scope) { (result) in
            completion(result.map({ $0.code }))
        }
    }

    private var thirdPartyCallbackCanceller: Cancellable?

    @available(iOS 9.0, *)
    public func open(_ url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme == configuration.redirectURI.scheme
            else { return false }

        var parameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        let stateParameterName = "state"
        guard let state = parameters.removeValue(forKey: stateParameterName) else { return false }

        thirdPartyCallbackCanceller = client.credentialService.thirdPartyCallback(
            state: state,
            parameters: parameters,
            completion: completion ?? { _ in }
        )

        return true
    }
}
