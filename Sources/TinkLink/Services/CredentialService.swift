import SwiftGRPC

final class CredentialService: TokenConfigurableService {
    let channel: Channel
    let metadata: Metadata

    init(channel: Channel, metadata: Metadata) {
        self.channel = channel
        self.metadata = metadata
    }

    internal lazy var service = CredentialServiceServiceClient(channel: channel, metadata: metadata)

    func credentials(completion: @escaping (Result<[Credential], Error>) -> Void) -> RetryCancellable {
        let request = GRPCListCredentialsRequest()

        return CallHandler(for: request, method: service.listCredentials, responseMap: { $0.credentials.map(Credential.init(grpcCredential:)) }, completion: completion)
    }

    func createCredential(providerID: Provider.ID, type: CredentialType = .unknown, fields: [String: String] = [:], completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCreateCredentialRequest()
        request.providerName = providerID.rawValue
        request.type = type.grpcCredentialType
        request.fields = fields

        return CallHandler(for: request, method: service.createCredential, responseMap: { Credential(grpcCredential: $0.credential) }, completion: completion)
    }

    func deleteCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDeleteCredentialRequest()
        request.credentialID = credentialID.rawValue

        return CallHandler(for: request, method: service.deleteCredential, responseMap: { _ in return }, completion: completion)
    }

    func updateCredential(credentialID: Credential.ID, fields: [String: String] = [:], completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable {
        var request = GRPCUpdateCredentialRequest()
        request.credentialID = credentialID.rawValue
        request.fields = fields

        return CallHandler(for: request, method: service.updateCredential, responseMap: { Credential(grpcCredential: $0.credential) }, completion: completion)
    }

    func refreshCredentials(credentialIDs: [Credential.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCRefreshCredentialsRequest()
        request.credentialIds = credentialIDs.map { $0.rawValue }

        return CallHandler(for: request, method: service.refreshCredentials, responseMap: { _ in return }, completion: completion)
    }

    func supplementInformation(credentialID: Credential.ID, fields: [String: String] = [:], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCSupplementInformationRequest()
        request.credentialID = credentialID.rawValue
        request.supplementalInformationFields = fields

        return CallHandler(for: request, method: service.supplementInformation, responseMap: { _ in return }, completion: completion)
    }

    func cancelSupplementInformation(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCancelSupplementInformationRequest()
        request.credentialID = credentialID.rawValue

        return CallHandler(for: request, method: service.cancelSupplementInformation, responseMap: { _ in return }, completion: completion)
    }

    func enableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCEnableCredentialRequest()
        request.credentialID = credentialID.rawValue

        return CallHandler(for: request, method: service.enableCredential, responseMap: { _ in return }, completion: completion)
    }

    func disableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDisableCredentialRequest()
        request.credentialID = credentialID.rawValue

        return CallHandler(for: request, method: service.disableCredential, responseMap: { _ in return }, completion: completion)
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCThirdPartyCallbackRequest()
        request.state = state
        request.parameters = parameters

        return CallHandler(for: request, method: service.thirdPartyCallback, responseMap: { _ in return }, completion: completion)
    }

    func manualAuthentication(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCManualAuthenticationRequest()
        request.credentialIds = credentialID.rawValue

        return CallHandler(for: request, method: service.manualAuthentication, responseMap: { _ in return }, completion: completion)
    }
}
