import Foundation

class URLSessionRequestRetryCancellable<T: Decodable, E: Decodable & Error>: RetryCancellable {
    private var session: URLSession
    private let request: URLRequest
    private var task: URLSessionTask?
    private var currentTask: URLSessionTask?
    private var completion: (Result<T, Error>) -> Void

    init(session: URLSession, request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
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
                let authorizationResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(authorizationResponse))
            } catch {
                let authorizationError = try? JSONDecoder().decode(E.self, from: data)
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
