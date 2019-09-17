import Foundation
import SwiftGRPC

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private var cancellable: Cancellable?
    private var service: UserService
    
    private init() {
        service = TinkLink.shared.client.userService
    }
    
    func authenticateIfNeeded<Service: TokenConfigurableServiceBase>(service otherService: Service, for market: Market = Market(code: "SE"), completion: @escaping (Result<AccessToken, Error>) -> Void) {
        if let accessToken = accessToken {
            otherService.configure(accessToken)
            self.accessToken = accessToken
            completion(.success(accessToken))
        } else {
            guard cancellable == nil else { return }
            cancellable = service.createAnonymous(market: Market(code: "SE")) { [weak self] result in
                guard let self = self else { return }
                do {
                    let accessToken = try result.get()
                    otherService.configure(accessToken)
                    self.accessToken = accessToken
                    completion(.success(accessToken))
                } catch let error as RPCError {
                    if let callResult = error.callResult {
                        switch callResult.statusCode {
                        case .unauthenticated:
                            // TODO: Auto retry? Maybe should use some auto retry handler for this same as the credential status polling
                            self.authenticateIfNeeded(service: otherService, for: market, completion: completion)
                        default:
                            completion(.failure(error))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
                self.cancellable = nil
            }
        }
    }
    
    private var accessToken: AccessToken?
}
