import Foundation

struct Client {
    let clientId: String
    let redirectUrl: URL
    var timeoutIntervalForRequest: TimeInterval = 15
}

extension Client: Decodable {
    enum CodingKeys: String, CodingKey {
        case clientId = "TINK_CLIENT_ID"
        case redirectUrl = "TINK_REDIRECT_URL"
        case timeoutInterval = "TINK_TIMEOUT_INTERVAL"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        clientId = try values.decode(String.self, forKey: .clientId)
        let redirectUrlString = try values.decode(String.self, forKey: .redirectUrl)
        timeoutIntervalForRequest = try values.decode(Double.self, forKey: .timeoutInterval)
        guard let redirectUrl = URL(string: redirectUrlString) else {
            fatalError("Invalid URL")
        }
        self.redirectUrl = redirectUrl
    }
}
