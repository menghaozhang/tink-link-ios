import SwiftGRPC

public final class StreamingService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service = StreamingServiceServiceClient(channel: channel)

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
