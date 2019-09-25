import Foundation

enum Environment {
    /// Default environment is production
    case production
    /// Use set tinkEnvironment environment for set staging environment, only for internal usage
    case staging
    case custom(URL)

    var url: URL {
        switch self {
        case .production:
            return URL(string: "main-grpc.production.oxford.tink.se:443")!
        case .staging:
            return URL(string: "main-grpc.staging.oxford.tink.se:443")!
        case .custom(let url):
            return url
        }
    }
}
