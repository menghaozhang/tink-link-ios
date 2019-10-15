import Foundation
#if os(iOS)
import UIKit
#endif

public class TinkLink {
    static var _shared: TinkLink?

    public static var shared: TinkLink {
        guard let shared = _shared else {
            let link = TinkLink()
            _shared = link
            return link
        }
        return shared
    }

    /// The current configuration.
    public let configuration: Configuration

    private(set) lazy var client = Client(configuration: configuration)

    lazy var providerStore = ProviderStore(tinkLink: self)
    lazy var credentialStore = CredentialStore()
    lazy var authenticationManager = AuthenticationManager(tinkLink: self)

    private init() {
        if let fallbackUrl = Bundle.main.url(forResource: "Info", withExtension: "plist") {
            do {
                let data = try Data(contentsOf: fallbackUrl)
                self.configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
            } catch {
                do {
                    self.configuration = try Configuration(processInfo: .processInfo)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        } else {
            do {
                self.configuration = try Configuration(processInfo: .processInfo)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public convenience init(configurationPlistURL url: URL) throws {
        let data = try Data(contentsOf: url)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        self.init(configuration: configuration)
    }

    /// Configure shared instance with URL to configration property list file.
    ///
    /// Here's how you could configure TinkLink using a property list:
    ///
    ///     let url = Bundle.main.url(forResource: "TinkLinkConfiguration", withExtension: "plist")!
    ///     TinkLink.configure(configurationPlistURL: url)
    ///
    public static func configure(configurationPlistURL url: URL) throws {
        precondition(_shared == nil, "Shared TinkLink instance is already configured.")
        _shared = try TinkLink(configurationPlistURL: url)
    }

    /// Configure shared instance with configration description.
    ///
    /// Here's how you could configure TinkLink with a `TinkLink.Configuration`.
    ///
    ///     let configuration = Configuration(clientID: "<#clientID#>", market: "SE", locale: "en_US")
    ///     TinkLink.configure(with: configuration)
    ///
    public static func configure(with configuration: TinkLink.Configuration) {
        precondition(_shared == nil, "Shared TinkLink instance is already configured.")
        _shared = TinkLink(configuration: configuration)
    }

    /// Creates an authorization code with the requested scopes for the current user
    ///
    /// Once you have received the authorization code, you can exchange it for an access token on your backend and use the access token to access the user's data. Exchanging the authorization code for an access token requires the use of the client secret associated with your client identifier.
    ///
    /// - Parameter scope: A comma separated list of OAuth scopes to be requested.
    /// - Parameter completion: The block to execute when the authorization is complete.
    /// - Parameter result: Represents either an authorization code if authorization was successful or an error if authorization failed.
    @discardableResult
    public func authorize(scope: String, completion: @escaping (_ result: Result<AuthorizationCode, Error>) -> Void) -> Cancellable? {
        return client.authenticationService.authorize(redirectURI: configuration.redirectURI, scope: scope) { result in
            completion(result.map { $0.code })
        }
    }

    @available(iOS 9.0, *)
    public func open(_ url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme == configuration.redirectURI.scheme
            else { return false }

        let allParameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        let stateParameterName = "state"
        let parameters = allParameters.filter { $0.key != stateParameterName }
        guard let state = allParameters[stateParameterName] else { return false }

        client.credentialService.thirdPartyCallback(
            state: state,
            parameters: parameters,
            completion: completion ?? { _ in }
        )

        return true
    }
}
