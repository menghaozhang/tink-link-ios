public protocol Cancellable {
    func cancel()
}

protocol Retriable {
    func retry()
}
