import Foundation
public class TinkLink {
    
    public struct Configuration {
        var clientId: String
        var redirectUrl: URL
        var timeoutIntervalForRequest: TimeInterval?
    }
    
    internal static let shared: TinkLink = TinkLink(client: TinkLink.client ?? fallbackClient)
    
    private static var client: Client?
    private(set) public static var timeoutIntervalForRequest: TimeInterval = 15
    
    private static let fallbackClient: Client = {
        let fallbackUrl = Bundle.main.url(forResource: "Info", withExtension: "plist")!
        do {
            let data = try Data(contentsOf: fallbackUrl)
            let configration = try PropertyListDecoder().decode(TinkLink.Configuration.self, from: data)
            return Client(clientId: configration.clientId, redirectUrl: configration.redirectUrl)
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
        client = Client(clientId: configuration.clientId,
                        redirectUrl: configuration.redirectUrl)
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
        case clientId = "TINK_CLIENT_ID"
        case redirectUrl = "TINK_REDIRECT_URL"
        case timeoutInterval = "TINK_TIMEOUT_INTERVAL"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        clientId = try values.decode(String.self, forKey: .clientId)
        timeoutIntervalForRequest = try? values.decode(Double.self, forKey: .timeoutInterval)
        let redirectUrlString = try values.decode(String.self, forKey: .redirectUrl)
        guard let redirectUrl = URL(string: redirectUrlString) else {
            fatalError("Invalid URL")
        }
        self.redirectUrl = redirectUrl
    }
}
