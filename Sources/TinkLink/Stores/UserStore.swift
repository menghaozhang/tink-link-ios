import Foundation

final class UserStore {
    static let shared = UserStore()
    
    private var cancellable: Cancellable?
    private var service: UserService
    
    private init() {
        service = TinkLink.shared.client.userService
    }
    
    func fetchAccessToken(for market: Market = Market(code: "SE"), completion: @escaping (Result<AccessToken, Error>) -> Void) {
        guard cancellable == nil else { return }
        cancellable = service.createAnonymous(market: Market(code: "SE")) { [weak self] result in
            guard let self = self else { return }
            if let accessToken = try? result.get() {
                self.accessToken = accessToken
            }
            self.cancellable = nil
            completion(result)
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
