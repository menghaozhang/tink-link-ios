import SwiftGRPC

typealias CallCompletionHandler<Model> = (Result<Model, Error>) -> Void

func startCall<Request, Response, Model>(
    for request: Request,
    method: (Request, @escaping (Response?, CallResult) -> Void) throws -> ClientCall,
    responseMap: @escaping (Response) -> Model,
    completion: @escaping CallCompletionHandler<Model>
    ) -> Cancellable {
    let canceller = CallCanceller()

    do {
        canceller.call = try method(request) { (response, result) in
            if let response = response {
                completion(.success(responseMap(response)))
            } else {
                let error = RPCError.callError(result)
                completion(.failure(error))
            }
        }
    } catch {
        completion(.failure(error))
    }

    return canceller
}
