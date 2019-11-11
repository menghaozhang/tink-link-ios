import SwiftGRPC

final class CallHandler<Request, Response, Model>: Cancellable, Retriable {
    typealias Method = (Request, @escaping (Response?, CallResult) -> Void) throws -> ClientCall
    typealias ResponseMap = (Response) -> Model
    typealias CallCompletionHandler<Model> = (Result<Model, Error>) -> Void

    var request: Request
    var method: Method
    var responseMap: ResponseMap
    var completion: CallCompletionHandler<Model>
    init(for request: Request, method: @escaping Method, responseMap: @escaping ResponseMap, completion: @escaping CallCompletionHandler<Model>) {
        self.request = request
        self.method = method
        self.responseMap = responseMap
        self.completion = completion
        startCall()
    }

    var call: ClientCall?

    func retry() {
        call?.cancel()
        startCall()
    }

    func cancel() {
        call?.cancel()
    }

    private func startCall() {
        do {
            call = try method(request) { [responseMap] response, result in
                if let response = response {
                    self.completion(.success(responseMap(response)))
                } else {
                    let error = RPCError.callError(result)
                    self.completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
