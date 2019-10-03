public protocol Cancellable {
    func cancel()
}

protocol Retriable {
    func retry()
}

typealias RetryCancellable = (Cancellable & Retriable)
