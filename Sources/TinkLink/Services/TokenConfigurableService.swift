import SwiftGRPC

protocol TokenConfigurableServiceBase {
    func config(_ accessToken: AccessToken)
}

protocol TokenConfigurableService: TokenConfigurableServiceBase {
    associatedtype ServiceClient: ServiceClientBase
    
    var service: ServiceClient { get set }
    func config(_ accessToken: AccessToken)
}

extension TokenConfigurableService {
    func config(_ accessToken: AccessToken) {
        do {
            try service.metadata.addAccessToken(accessToken.rawValue)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
