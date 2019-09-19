private class AnyCancellable {
    private var cancellable: Cancellable

    init(cancellable: Cancellable) {
        self.cancellable = cancellable
    }

    func cancel() {
        cancellable.cancel()
    }
}

class MultiCanceller: Cancellable {
    private var cancellers: [AnyCancellable] = []

    private(set) var isCancelled: Bool = false

    func add(_ canceller: Cancellable) {
        cancellers.append(AnyCancellable(cancellable: canceller))
    }

    func cancel() {
        isCancelled = true
        for canceller in cancellers {
            canceller.cancel()
        }
    }
}
