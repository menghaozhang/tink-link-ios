import Foundation

final class UserStore {
    static let shared = UserStore()
    
    private init() {
        client = TinkLink.shared.client
        service = TinkLink.shared.client.userService
    }
    private var client: Client
    private var service: UserService
    private var cancellable: Cancellable?
    
    func getAccessToken(market: Market, locale: Locale = Locale(identifier: "en_US") , origin: String?, completion: @escaping ((Result<AccessToken, Error>) -> Void)) {
        guard cancellable == nil else {
            return
        }
        cancellable = service.createAnonymous(market: market, locale: locale, origin: origin) { [weak self] result in
            if let accessToken = try? result.get() {
                self?.client.accessToken = accessToken
            }
            completion(result)
            self?.cancellable = nil
        }
    }
}
