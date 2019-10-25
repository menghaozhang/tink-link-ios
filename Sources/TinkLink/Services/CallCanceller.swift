import SwiftGRPC

final class CallCanceller: Cancellable {
    var call: ClientCall?

    deinit {
        cancel()
    }

    func cancel() {
        call?.cancel()
    }
}
