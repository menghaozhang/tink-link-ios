import SwiftGRPC

public final class CredentialService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service = CredentialServiceServiceClient(channel: channel)

    func credentials(completion: @escaping (Result<[GRPCCredential], Error>) -> Void) -> Cancellable {
        let request = GRPCListCredentialsRequest()

        return startCall(for: request, method: service.listCredentials, responseMap: { $0.credentials }, completion: completion)
    }
}
