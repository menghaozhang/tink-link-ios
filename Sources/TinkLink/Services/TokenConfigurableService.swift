import SwiftGRPC

protocol TokenConfigurableServiceBase {
    func configure(_ accessToken: AccessToken)
}

protocol TokenConfigurableService: TokenConfigurableServiceBase {
    associatedtype ServiceClient: ServiceClientBase
    
    var service: ServiceClient { get set }
}

extension TokenConfigurableService {
    func configure(_ accessToken: AccessToken) {
        do {
            try service.metadata.addAccessToken(accessToken.rawValue)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
