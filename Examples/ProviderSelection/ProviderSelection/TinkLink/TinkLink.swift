import Foundation
public class TinkLink {
    internal static let shared: TinkLink = TinkLink(client: TinkLink.client ?? fallbackClient)
    
    private static var client: Client?
    
    private static let fallbackClient: Client = {
        let fallbackUrl = Bundle.main.bundleURL
        do {
            let data = try Data(contentsOf: fallbackUrl)
            return try PropertyListDecoder().decode(Client.self, from: data)
        } catch {
            fatalError("Cannot find client")
        }
    }()
    
    // Setup via configration files
    public static func configure(tinklinkUrl: URL) throws {
        let data = try Data(contentsOf: tinklinkUrl)
        client = try PropertyListDecoder().decode(Client.self, from: data)
    }
    
    // Setup via configration object
    public static func configure(with configuration: TinkLinkConfiguration) {
        client = Client(clientId: configuration.clientId,
                        redirectUrl: configuration.redirectUrl,
                        timeoutIntervalForRequest: configuration.timeoutIntervalForRequest)
    }
    
    //
    public static func configure(timeoutInterval: TimeInterval) {
        TinkLink.shared.client.timeoutIntervalForRequest = timeoutInterval
    }
    
    private init(client: Client) {
        self.client = client
    }
    
    var client: Client
}

public struct TinkLinkConfiguration {
    var clientId: String
    var redirectUrl: URL
    var timeoutIntervalForRequest: TimeInterval
}
