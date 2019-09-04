import Foundation

public enum Environment: String, RawRepresentable {
    case production
    case staging

    var url: URL {
        switch self {
        case .production:
            return URL(string: "main-grpc.production.oxford.tink.se:443")!
        case .staging:
            return URL(string: "main-grpc.staging.oxford.tink.se:443")!
        }
    }
}
