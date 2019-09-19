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

    func add(_ canceller: Cancellable) {
        cancellers.append(AnyCancellable(cancellable: canceller))
    }

    func cancel() {
        for canceller in cancellers {
            canceller.cancel()
        }
    }
}
