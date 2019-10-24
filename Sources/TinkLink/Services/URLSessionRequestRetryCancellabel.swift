import Foundation

class URLSessionRequestRetryCancellable: RetryCancellable {
    private var session: URLSession
    private let request: URLRequest
    private var task: URLSessionTask?
    private var currentTask: URLSessionTask?
    private var completion: (Result<AuthorizationResponse, Error>) -> Void

    init(session: URLSession, request: URLRequest, completion: @escaping (Result<AuthorizationResponse, Error>) -> Void) {
        self.session = session
        self.request = request
        self.completion = completion
    }

    func start() {
        let task = session.dataTask(with: request) { [weak self] data, _, error in
            self?.handle(data: data, error: error)
        }

        task.resume()
        self.task = task
    }

    private func handle(data: Data?, error: Error?) {
        if let data = data {
            do {
                let authorizationResponse = try JSONDecoder().decode(AuthorizationResponse.self, from: data)
                completion(.success(authorizationResponse))
            } catch {
                let authorizationError = try? JSONDecoder().decode(AuthorizationError.self, from: data)
                completion(.failure(authorizationError ?? error))
            }
        } else if let error = error {
            completion(.failure(error))
        } else {
            completion(.failure(URLError(.unknown)))
        }
    }

    // MARK: - Cancellable
    func cancel() {
        task?.cancel()
    }

    // MARK: - Retriable
    func retry() {
        start()
    }
}
