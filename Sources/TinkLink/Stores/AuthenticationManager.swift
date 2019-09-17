import Foundation

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private var cancellable: Cancellable?
    private var service: UserService
    
    private init() {
        service = TinkLink.shared.client.userService
    }
    
    func authenticateIfNeeded<Service: TokenConfigurableServiceBase>(service otherService: Service, for market: Market = Market(code: "SE"), completion: @escaping (AccessToken) -> Void) {
        if let accessToken = accessToken {
            otherService.configure(accessToken)
            completion(accessToken)
        } else {
            guard cancellable == nil else { return }
            cancellable = service.createAnonymous(market: Market(code: "SE")) { [weak self] result in
                guard let self = self else { return }
                if let accessToken = try? result.get() {
                    otherService.configure(accessToken)
                    self.accessToken = accessToken
                    completion(accessToken)
                } else {
                    // TODO: Auto retry? Maybe should use some auto retry handler for this same as the credential status polling
                    self.authenticateIfNeeded(service: otherService, for: market, completion: completion)
                }
                self.cancellable = nil
            }
        }
    }
    
    var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                NotificationCenter.default.post(name: .accessTokenChanged, object: self, userInfo: ["access_token": accessToken])
            }
        }
    }
}

extension Notification.Name {
    static let accessTokenChanged = Notification.Name("TinkLinkAccessTokenChangedNotificationName")
}
