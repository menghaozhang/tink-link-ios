import Foundation
import SwiftGRPC

typealias RetryCancellable = (Cancellable & Retriable)

final class AuthenticationManager {
    private var retryCancellable: RetryCancellable?
    private var service: UserService
    private var completionHandlers: [(Result<Void, Error>) -> Void] = []
    
    init(tinkLink: TinkLink = .shared) {
        service = tinkLink.client.userService
    }
    
    func authenticateIfNeeded<Service: TokenConfigurableService>(service otherService: Service, for market: Market, locale: Locale, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let accessToken = accessToken {
            otherService.configure(accessToken)
            self.accessToken = accessToken
            completion(.success(()))
        } else {
            if retryCancellable == nil {
                retryCancellable = service.createAnonymous(market: market, locale: locale) { [weak self] result in
                    guard let self = self else { return }
                    do {
                        let accessToken = try result.get()
                        otherService.configure(accessToken)
                        self.accessToken = accessToken
                        completion(.success(()))
                        self.completionHandlers.forEach{ $0(.success(())) }
                        self.completionHandlers.removeAll()
                    } catch let error as RPCError {
                        completion(.failure(error))
                        self.completionHandlers.forEach{ $0(.failure(error)) }
                        self.completionHandlers.removeAll()
                    } catch {
                        completion(.failure(error))
                        self.completionHandlers.forEach{ $0(.failure(error)) }
                        self.completionHandlers.removeAll()
                    }
                    self.retryCancellable = nil
                }
            } else {
                // In case of multiple requests at the same time
                completionHandlers.append(completion)
            }
        }
        return retryCancellable
    }
    
    private var accessToken: AccessToken?
}
