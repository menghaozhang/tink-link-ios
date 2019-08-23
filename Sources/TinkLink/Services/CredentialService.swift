import SwiftGRPC

public final class CredentialService {
    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    private lazy var service: CredentialServiceServiceClient = {
        let service = CredentialServiceServiceClient(channel: channel)
        do {
            try service.metadata.addTinkMetadata()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return service
    }()

    public func credentials(completion: @escaping (Result<[Credential], Error>) -> Void) -> Cancellable {
        let request = GRPCListCredentialsRequest()

        return startCall(for: request, method: service.listCredentials, responseMap: { $0.credentials.map(Credential.init(grpcCredential:)) }, completion: completion)
    }

    public func createCredential(providerName: String, type: Credential.`Type` = .unknown, fields: [String: String] = [:], completion: @escaping (Result<Credential, Error>) -> Void) -> Cancellable {
        var request = GRPCCreateCredentialRequest()
        request.providerName = providerName
        request.type = type.grpcCredentialType
        request.fields = fields

        return startCall(for: request, method: service.createCredential, responseMap: { Credential(grpcCredential: $0.credential) }, completion: completion)
    }

    public func deleteCredential(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCDeleteCredentialRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.deleteCredential, responseMap: { _ in return }, completion: completion)
    }

    public func updateCredential(credentialID: String, fields: [String: String] = [:], completion: @escaping (Result<Credential, Error>) -> Void) -> Cancellable {
        var request = GRPCUpdateCredentialRequest()
        request.credentialID = credentialID
        request.fields = fields

        return startCall(for: request, method: service.updateCredential, responseMap: { Credential(grpcCredential: $0.credential) }, completion: completion)
    }

    public func refreshCredentials(credentialIDs: [String], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCRefreshCredentialsRequest()
        request.credentialIds = credentialIDs

        return startCall(for: request, method: service.refreshCredentials, responseMap: { _ in return }, completion: completion)
    }

    public func supplementInformation(credentialID: String, fields: [String: String] = [:], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCSupplementInformationRequest()
        request.credentialID = credentialID
        request.supplementalInformationFields = fields

        return startCall(for: request, method: service.supplementInformation, responseMap: { _ in return }, completion: completion)
    }

    public func cancelSupplementInformation(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCCancelSupplementInformationRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.cancelSupplementInformation, responseMap: { _ in return }, completion: completion)
    }

    public func enableCredential(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCEnableCredentialRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.enableCredential, responseMap: { _ in return }, completion: completion)
    }

    public func disableCredential(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCDisableCredentialRequest()
        request.credentialID = credentialID

        return startCall(for: request, method: service.disableCredential, responseMap: { _ in return }, completion: completion)
    }

    public func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCThirdPartyCallbackRequest()
        request.state = state
        request.parameters = parameters

        return startCall(for: request, method: service.thirdPartyCallback, responseMap: { _ in return }, completion: completion)
    }

    public func manualAuthentication(credentialID: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable {
        var request = GRPCManualAuthenticationRequest()
        request.credentialIds = credentialID

        return startCall(for: request, method: service.manualAuthentication, responseMap: { _ in return }, completion: completion)
    }
}
