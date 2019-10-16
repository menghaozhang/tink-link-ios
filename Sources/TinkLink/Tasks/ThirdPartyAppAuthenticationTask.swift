import Foundation
#if os(iOS)
import UIKit
#endif

public class ThirdPartyAppAuthenticationTask {
    public enum Error: Swift.Error, LocalizedError {
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

    public private(set) var thirdPartyAppAuthentication: Credential.ThirdPartyAppAuthentication

    private let completionHandler: (Result<Void, Swift.Error>) -> Void

    init(thirdPartyAppAuthentication: Credential.ThirdPartyAppAuthentication, completionHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
        self.thirdPartyAppAuthentication = thirdPartyAppAuthentication
        self.completionHandler = completionHandler
    }

    #if os(iOS)
    public func openThirdPartyApp(with application: UIApplication = .shared) {
        guard let url = thirdPartyAppAuthentication.deepLinkURL else {
            completionHandler(.failure(Error.deeplinkURLNotFound))
            return
        }

        let downloadRequiredError = Error.downloadRequired(
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
    #endif

    public func cancel() {
        completionHandler(.failure(CocoaError(.userCancelled)))
    }
}
