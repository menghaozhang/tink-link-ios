import Foundation
#if os(iOS)
import UIKit
#endif

public class TinkLink {
    static var _shared: TinkLink?

    public static var shared: TinkLink {
        guard let shared = _shared else {
            fatalError("Configure Tink Link by calling `TinkLink.configure()` before accessing the shared instance")
        }
        return shared
    }

    /// The current configuration.
    public let configuration: Configuration

    private(set) lazy var client = Client(configuration: configuration)

    private init() {
        do {
            self.configuration = try Configuration(processInfo: .processInfo)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Create a TinkLink instance with a custom configuration.
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// Configure shared instance with configration description.
    ///
    /// Here's how you could configure TinkLink with a `TinkLink.Configuration`.
    ///
    ///     let configuration = Configuration(clientID: "<#clientID#>", redirectURI: <#URL#>, market: "<#SE#>", locale: .current)
    ///     TinkLink.configure(with: configuration)
    ///
    public static func configure(with configuration: TinkLink.Configuration) {
        _shared = TinkLink(configuration: configuration)
    }

    private var thirdPartyCallbackCanceller: Cancellable?

    @available(iOS 9.0, *)
    public func open(_ url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme == configuration.redirectURI.scheme
            else { return false }

        var parameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        let stateParameterName = "state"
        guard let state = parameters.removeValue(forKey: stateParameterName) else { return false }

        thirdPartyCallbackCanceller = client.credentialService.thirdPartyCallback(
            state: state,
            parameters: parameters,
            completion: completion ?? { _ in }
        )

        return true
    }
}
