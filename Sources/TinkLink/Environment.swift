import Foundation

public enum Environment {
    /// Default environment is production
    case production
    case custom(grpcURL: URL, restURL: URL)

    var grpcURL: URL {
        switch self {
        case .production:
            return URL(string: "main-grpc.production.oxford.tink.se:443")!
        case .custom(let url, _):
            return url
        }
    }

    var restURL: URL {
        switch self {
        case .production:
            return URL(string: "https://api.tink.com")!
        case .custom(_, let url):
            return url
        }
    }
}
