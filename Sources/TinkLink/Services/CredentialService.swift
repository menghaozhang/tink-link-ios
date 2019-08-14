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

    func createCredential(providerName: String, type: GRPCCredential.TypeEnum = .unknown, fields: [String: String] = [:], completion: @escaping (Result<GRPCCredential, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateCredentialRequest()
        request.providerName = providerName
        request.type = type
        request.fields = fields

        return startCall(for: request, method: service.createCredential, responseMap: { $0.credential }, completion: completion)
    }

    func deleteCredential(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCDeleteCredentialRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.deleteCredential, responseMap: { _ in return }, completion: completion)
    }

    func updateCredential(credentialID: String, fields: [String: String] = [:], completion: @escaping (Result<GRPCCredential, Error>) -> Void) -> Cancellable {
        var request = GRPCUpdateCredentialRequest()
        request.credentialID = credentialID
        request.fields = fields

        return startCall(for: request, method: service.updateCredential, responseMap: { $0.credential }, completion: completion)
    }

    func refreshCredentials(credentialIDs: [String], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCRefreshCredentialsRequest()
        request.credentialIds = credentialIDs

        return startCall(for: request, method: service.refreshCredentials, responseMap: { _ in return }, completion: completion)
    }

    func supplementInformation(credentialID: String, fields: [String: String] = [:], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCSupplementInformationRequest()
        request.credentialID = credentialID
        request.supplementalInformationFields = fields

        return startCall(for: request, method: service.supplementInformation, responseMap: { _ in return }, completion: completion)
    }

    func cancelSupplementInformation(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCCancelSupplementInformationRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.cancelSupplementInformation, responseMap: { _ in return }, completion: completion)
    }

    func enableCredential(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCEnableCredentialRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.enableCredential, responseMap: { _ in return }, completion: completion)
    }

    func disableCredential(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCDisableCredentialRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.disableCredential, responseMap: { _ in return }, completion: completion)
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCThirdPartyCallbackRequest()
        request.state = state
        request.parameters = parameters

        return startCall(for: request, method: service.thirdPartyCallback, responseMap: { _ in return }, completion: completion)
    }
}
