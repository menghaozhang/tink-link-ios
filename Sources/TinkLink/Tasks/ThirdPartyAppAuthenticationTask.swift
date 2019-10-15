import UIKit

public enum ThirdPartyAppAuthenticationError: Error, LocalizedError {
    case deeplinkURLNotFound
    case downloadRequired(title: String, message: String, appStoreURL: URL?)

    public var errorDescription: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(let title, _, _):
            return title
        }
    }

    public var failureReason: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(_, let message, _):
            return message
        }
    }

    public var appStoreURL: URL? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(_, _, let url):
            return url
        }
    }
}

public class ThirdPartyAppAuthenticationTask {
    private let credentialService: CredentialService
    public private(set) var credential: Credential

    private let completionHandler: (Result<Void, Error>) -> Void

    init(tinkLink: TinkLink = .shared, credential: Credential, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.credentialService = tinkLink.client.credentialService
        self.credential = credential
        self.completionHandler = completionHandler
    }

    @available(iOS 10.0, *)
    public func open(with application: UIApplication = .shared) {
        guard let thirdPartyAppAuthentication = credential.thirdPartyAppAuthentication else {
            completionHandler(.failure(ThirdPartyAppAuthenticationError.deeplinkURLNotFound))
            return
        }

        guard let url = thirdPartyAppAuthentication.deepLinkURL else {
            completionHandler(.failure(ThirdPartyAppAuthenticationError.deeplinkURLNotFound))
            return
        }

        let downloadRequiredError = ThirdPartyAppAuthenticationError.downloadRequired(
            title: thirdPartyAppAuthentication.downloadTitle,
            message: thirdPartyAppAuthentication.downloadMessage,
            appStoreURL: thirdPartyAppAuthentication.appStoreURL
        )

        guard UIApplication.shared.canOpenURL(url) else {
            completionHandler(.failure(downloadRequiredError))
            return
        }

        application.open(url, options: [.universalLinksOnly: NSNumber(value: true)]) { (didOpenUniversalLink) in
            if didOpenUniversalLink {
                self.completionHandler(.success(()))
            } else {
                application.open(url, options: [:], completionHandler: { (didOpen) in
                    if didOpen {
                        self.completionHandler(.success(()))
                    } else {
                        self.completionHandler(.failure(downloadRequiredError))
                    }
                })
            }
        }
    }
}
