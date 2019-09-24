class MultiHandler: Cancellable, Retriable {
    private var handlers: [Cancellable & Retriable] = []

    private(set) var isCancelled: Bool = false
    private(set) var hasRetried: Bool = false

    func add(_ handler: Cancellable & Retriable) {
        handlers.append(handler)
    }

    func cancel() {
        isCancelled = true
        for handler in handlers {
            handler.cancel()
        }
    }
    
    func retry() {
        hasRetried = true
        for handler in handlers {
            handler.retry()
        }
    }
}
