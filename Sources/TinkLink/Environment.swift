import Foundation

public enum Environment {
    /// Default environment is production
    case production
    /// Use set tinkEnvironment environment for set staging environment, only for internal usage
    case staging
    case custom(grpcURL: URL, restURL: URL)

    var grpcURL: URL {
        switch self {
        case .production:
            return URL(string: "main-grpc.production.oxford.tink.se:443")!
        case .staging:
            return URL(string: "main-grpc.staging.oxford.tink.se:443")!
        case .custom(let url, _):
            return url
        }
    }

    var restURL: URL {
        switch self {
        case .production:
            return URL(string: "https://api.tink.com")!
        case .staging:
            fatalError()
        case .custom(_, let url):
            return url
        }
    }
}
