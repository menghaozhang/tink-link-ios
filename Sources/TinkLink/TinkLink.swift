import Foundation

public class TinkLink {
    public struct Configuration {
        var environment: Environment
        var clientId: String
        var redirectUrl: URL
        var timeoutIntervalForRequest: TimeInterval?
        var certificateURL: URL?
        public init (environment: Environment, clientId: String, redirectUrl: URL, timeoutIntervalForRequest: TimeInterval? = nil, certificateURL: URL? = nil) {
            self.environment = environment
            self.clientId = clientId
            self.redirectUrl = redirectUrl
            self.timeoutIntervalForRequest = timeoutIntervalForRequest
            self.certificateURL = certificateURL
        }
    }
    
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

    private(set) public static var timeoutIntervalForRequest: TimeInterval = 15
    
    // Setup via configration files
    public static func configure(tinklinkUrl: URL) throws {
        let data = try Data(contentsOf: tinklinkUrl)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        configure(with: configuration)
    }
    
    // Setup via configration object
    public static func configure(with configuration: TinkLink.Configuration) {
        shared._client = Client(environment: configuration.environment , clientKey: configuration.clientId, certificateURL: configuration.certificateURL)
    }
    
    // TODO: Some configurations can be changed after setup, for example timeoutIntervalForRequest and Qos, the changes should reflect to the stores and services
    public static func configure(timeoutInterval: TimeInterval) {
        TinkLink.timeoutIntervalForRequest = timeoutInterval
    }
    
    public static func warmUp() {
        UserStore.shared.fetchAccessToken { _ in }
    }
    
    private init() {

    }
    
    var timeoutIntervalForRequest: TimeInterval {
        return TinkLink.timeoutIntervalForRequest
    }
}

extension TinkLink.Configuration: Decodable {
    enum CodingKeys: String, CodingKey {
        case environment = "TINK_ENVIRONMENT"
        case clientId = "TINK_CLIENT_ID"
        case redirectUrl = "TINK_REDIRECT_URL"
        case timeoutInterval = "TINK_TIMEOUT_INTERVAL"
        case certificateFileName = "TINK_CERTIFICATE_FILE_NAME"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        clientId = try values.decode(String.self, forKey: .clientId)
        timeoutIntervalForRequest = try? values.decode(Double.self, forKey: .timeoutInterval)
        if let environmentString = try? values.decode(String.self, forKey: .environment),
            let environment = Environment(rawValue: environmentString) {
            self.environment = environment
        } else {
            self.environment = .production
        }
        let redirectUrlString = try values.decode(String.self, forKey: .redirectUrl)
        guard let redirectUrl = URL(string: redirectUrlString) else {
            fatalError("Invalid redirect URL")
        }
        self.redirectUrl = redirectUrl

        if let certificateFileName = try values.decodeIfPresent(String.self, forKey: .certificateFileName) {
            guard let certificateURL = Bundle.main.url(forResource: certificateFileName, withExtension: "pem") else {
                fatalError("Cannot find certificate file")
            }
            self.certificateURL = certificateURL
        }
    }
}

extension Client {
    convenience init(configurationUrl: URL) throws {
        let data = try Data(contentsOf: configurationUrl)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        self.init(environment: configuration.environment, clientKey: configuration.clientId, certificateURL: configuration.certificateURL)
    }

    convenience init?(processInfo: ProcessInfo) {
        guard let clientKey = processInfo.tinkClientKey else { return nil }
        self.init(
            environment: processInfo.tinkEnvironment ?? .staging,
            clientKey: clientKey,
            certificate: processInfo.tinkCertificate
        )
    }
}
