import Foundation
import SwiftGRPC

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private var cancellable: Cancellable?
    private var service: UserService
    private var completionHandlers: [(Result<Void, Error>) -> Void] = []
    
    private init() {
        service = TinkLink.shared.client.userService
    }
    
    func authenticateIfNeeded<Service: TokenConfigurableService>(service otherService: Service, for market: Market, locale: Locale, completion: @escaping (Result<Void, Error>) -> Void) {
        if let accessToken = accessToken {
            otherService.configure(accessToken)
            self.accessToken = accessToken
            completion(.success(()))
        } else {
            if cancellable == nil {
                cancellable = service.createAnonymous(market: market, locale: locale) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        let accessToken = try result.get()
                        otherService.configure(accessToken)
                        self.accessToken = accessToken
                        completion(.success(()))
                        self.completionHandlers.forEach{ $0(.success(())) }
                        self.completionHandlers.removeAll()
                    } catch let error as RPCError {
                        if let callResult = error.callResult {
                            switch callResult.statusCode {
                            case .unauthenticated:
                                // TODO: Auto retry? Maybe should use some auto retry handler for this same as the credential status polling
                                self.authenticateIfNeeded(service: otherService, for: market, locale: locale, completion: completion)
                            default:
                                completion(.failure(error))
                                self.completionHandlers.forEach{ $0(.failure(error)) }
                                self.completionHandlers.removeAll()
                            }
                        }
                    } catch {
                        completion(.failure(error))
                        self.completionHandlers.forEach{ $0(.failure(error)) }
                        self.completionHandlers.removeAll()
                    }
                    self.cancellable = nil
                }
            } else {
                // In case of multiple requests at the same time
                completionHandlers.append(completion)
            }
        }
    }
    
    private var accessToken: AccessToken?
}
