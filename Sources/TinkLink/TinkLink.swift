import Foundation

public class TinkLink {
    public static let shared: TinkLink = TinkLink()

    private var configuration: Configuration!

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
        self.client = Client(environment: configuration.environment , clientID: configuration.clientID, certificateURL: configuration.certificateURL, market: configuration.market, locale: configuration.locale)
    }

    public convenience init(configurationPlistURL url: URL) throws {
        let data = try Data(contentsOf: url)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        self.init(configuration: configuration)
    }

    // Setup via configration files
    public static func configure(tinklinkUrl: URL) throws {
        let data = try Data(contentsOf: tinklinkUrl)
        shared.configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
    }

    // Setup via configration object
    public static func configure(with configuration: TinkLink.Configuration) {
        shared.configuration = configuration
    }
}
