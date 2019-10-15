#if os(iOS)
import UIKit
#endif

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
    public private(set) var thirdPartyAppAuthentication: Credential.ThirdPartyAppAuthentication

    private let completionHandler: (Result<Void, Error>) -> Void

    init(thirdPartyAppAuthentication: Credential.ThirdPartyAppAuthentication, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.thirdPartyAppAuthentication = thirdPartyAppAuthentication
        self.completionHandler = completionHandler
    }

    @available(iOS 10.0, *)
    public func open(with application: UIApplication = .shared) {
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
