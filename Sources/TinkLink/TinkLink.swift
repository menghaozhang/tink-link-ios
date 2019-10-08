import Foundation

public class TinkLink {
    static var _shared: TinkLink?

    public static var shared: TinkLink {
        guard let shared = _shared else {
            do {
                let link = try TinkLink()
                _shared = link
                return link
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        return shared
    }

    /// The current configuration.
    public let configuration: Configuration

    private(set) lazy var client = Client(configuration: configuration)

    lazy var providerStore = ProviderStore(tinkLink: self)
    lazy var credentialStore = CredentialStore(tinkLink: self)
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

    /// Get authorization code for requested scopes.
    ///
    /// Once you have received the authorization code, pass it to your backend service to exchange it for an access token. This must be done using the client secret, which you received with your client id.
    ///
    /// - Parameter scope: The requested OAuth scopes The scope parameter can receive multiple scopes separated by a comma.
    /// - Parameter completion: The block to execute when the authorization is complete.
    /// - Parameter result: Represents either a code if authorization was successful or an error if it failed.
    @discardableResult
    public func authorize(scope: String, completion: @escaping (_ result: Result<AuthorizationCode, Error>) -> Void) -> Cancellable? {
        guard let redirectURI = configuration.redirectURI else {
            preconditionFailure("No Redirect URI set")
        }
        return client.authenticationService.authorize(redirectURI: redirectURI, scope: scope) { (result) in
            completion(result.map({ $0.code }))
        }
    }
}
