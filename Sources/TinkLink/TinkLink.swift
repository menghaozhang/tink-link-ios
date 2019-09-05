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
    
    internal static let shared: TinkLink = TinkLink(client: TinkLink.client ?? fallbackClient)
    
    private static var client: Client?
    private(set) public static var timeoutIntervalForRequest: TimeInterval = 15
    
    private static let fallbackClient: Client = {
        let fallbackUrl = Bundle.main.url(forResource: "Info", withExtension: "plist")!
        do {
            let data = try Data(contentsOf: fallbackUrl)
            let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
            
            return Client(environment: .production, clientKey: configuration.clientId)
        } catch {
            fatalError("Cannot find client")
        }
    }()
    
    // Setup via configration files
    public static func configure(tinklinkUrl: URL) throws {
        let data = try Data(contentsOf: tinklinkUrl)
        let configuration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
        configure(with: configuration)
    }
    
    // Setup via configration object
    public static func configure(with configuration: TinkLink.Configuration) {
        client = Client(environment: configuration.environment , clientKey: configuration.clientId, certificateURL: configuration.certificateURL)
    }
    
    // TODO: Some configurations can be changed after setup, for example timeoutIntervalForRequest and Qos, the changes should reflect to the stores and services
    public static func configure(timeoutInterval: TimeInterval) {
        TinkLink.timeoutIntervalForRequest = timeoutInterval
    }
    
    private init(client: Client) {
        self.client = client
    }
    
    let client: Client
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
        let certificateFileName = try values.decode(String.self, forKey: .certificateFileName)
        guard let redirectUrl = URL(string: redirectUrlString) else {
            fatalError("Invalid redirect URL")
        }
        guard let certificateURL = Bundle.main.url(forResource: certificateFileName, withExtension: "pem") else {
            fatalError("Cannot find certificate file")
        }
        self.certificateURL = certificateURL
        self.redirectUrl = redirectUrl
    }
}
