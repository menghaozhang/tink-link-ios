import Dispatch
import SwiftGRPC

final class StreamingService {
    let channel: Channel
    let metadata: Metadata

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    private lazy var service: StreamingServiceServiceClient = {
        let service = StreamingServiceServiceClient(channel: channel)
        service.metadata = metadata
        return service
    }()

    private lazy var receiverQueue = DispatchQueue(label: "com.tink.TinkLink.StreamingService.receiver")

    func stream(onEvent eventHandler: @escaping (GRPCStreamingResponse) -> Void, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        let canceller = CallCanceller()

        do {
            let call = try service.stream { (callResult) in
                if callResult.success {
                    switch callResult.statusCode {
                    case .ok:
                        completion(.success(()))
                    case .cancelled:
                        break
                    default:
                        let error = RPCError.callError(callResult)
                        completion(.failure(error))
                    }
                } else {
                    let error = RPCError.callError(callResult)
                    completion(.failure(error))
                }
            }

            canceller.call = call

            receiverQueue.async {
                do {
                    while let response = try call.receive() {
                        eventHandler(response)
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }

        return canceller
    }
}
