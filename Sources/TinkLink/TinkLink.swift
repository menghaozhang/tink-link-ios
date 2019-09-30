import Foundation

public class TinkLink {
    private static var _shared: TinkLink?

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
        _shared = TinkLink(configuration: configuration)
    }
}
