import Foundation

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private var cancellable: Cancellable?
    private var service: UserService
    private var completionHandlers: [(AccessToken) -> Void] = []
    
    private init() {
        service = TinkLink.shared.client.userService
        authenticate()
    }
    
    func authenticate() {
        authenticateIfNeeded { _ in }
    }
    
    func authenticateIfNeeded(for market: Market = Market(code: "SE"), completion: @escaping (AccessToken) -> Void) {
        if let accessToken = accessToken {
            completion(accessToken)
        } else {
            if cancellable == nil {
                cancellable = service.createAnonymous(market: Market(code: "SE")) { [weak self] result in
                    guard let self = self else { return }
                    if let accessToken = try? result.get() {
                        self.accessToken = accessToken
                        self.completionHandlers.forEach{ $0(accessToken) }
                        self.completionHandlers.removeAll()
                    } else {
                        // TODO: Auto retry? Maybe should use some auto retry handler for this same as the credential status polling
                        self.authenticateIfNeeded(for: market, completion: completion)
                    }
                    self.cancellable = nil
                }
            } else {
                // In case of multiple requests at the same time
                completionHandlers.append(completion)
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
