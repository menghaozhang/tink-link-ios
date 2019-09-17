import SwiftGRPC

extension ServiceClientBase {
    convenience init(channel: Channel, metadata: Metadata) {
        self.init(channel: channel)
        self.metadata = metadata
    }
}
