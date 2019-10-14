import SwiftGRPC

protocol TokenConfigurableService {
    associatedtype ServiceClient: ServiceClientBase

    var service: ServiceClient { get set }

    func configure(_ accessToken: AccessToken)
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
