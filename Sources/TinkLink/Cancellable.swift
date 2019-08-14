import SwiftGRPC

public class Cancellable {
    var call: ClientCall?

    init(call: ClientCall? = nil) {
        self.call = call
    }

    deinit {
        cancel()
    }

    public func cancel() {
        call?.cancel()
    }
}
