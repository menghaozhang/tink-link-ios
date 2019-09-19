class MultiCanceller: Cancellable {
    private var cancellers: [Cancellable] = []

    private(set) var isCancelled: Bool = false

    func add(_ canceller: Cancellable) {
        cancellers.append(canceller)
    }

    func cancel() {
        isCancelled = true
        for canceller in cancellers {
            canceller.cancel()
        }
    }
}
