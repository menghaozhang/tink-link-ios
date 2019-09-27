import Foundation

public class TinkLink {
    
    public init() {}
    public static let shared: TinkLink = TinkLink()
    
    private var _client: Client?
    private(set) var client: Client {
        get {
            if let client = _client {
                return client
            } else if let fallbackUrl = Bundle.main.url(forResource: "Info", withExtension: "plist") {
                do {
                    _client = try Client(configurationUrl: fallbackUrl)
                } catch {
                    if let client = Client(processInfo: .processInfo) {
                        _client = client
                    } else {
                        fatalError("Cannot find client")
                    }
                }
                return _client!
            } else if let client = Client(processInfo: .processInfo) {
                _client = client
                return _client!
            } else {
                fatalError("Cannot find client")
            }
        }
        set {
            _client = newValue
        }
    }
    
    // Setup via configration files
    public static func configure(tinklinkUrl: URL) throws {
        let data = try Data(contentsOf: tinklinkUrl)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        configure(with: configuration)
    }
    
    // Setup via configration object
    public static func configure(with configuration: TinkLink.Configuration) {
        shared._client = Client(environment: configuration.environment , clientID: configuration.clientID, certificateURL: configuration.certificateURL, market: configuration.market, locale: configuration.locale)
    }
    // TODO: Some configurations can be changed after setup, for example timeoutIntervalForRequest and Qos, the changes should reflect to the stores and services
    
    // Used to setup additional TinkLink object
    public func configure(tinklinkUrl: URL) throws {
        let data = try Data(contentsOf: tinklinkUrl)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        configure(with: configuration)
    }
    
    public func configure(with configuration: TinkLink.Configuration) {
        _client = Client(environment: configuration.environment , clientID: configuration.clientID, certificateURL: configuration.certificateURL, market: configuration.market, locale: configuration.locale)
    }
}
