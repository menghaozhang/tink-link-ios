import Foundation

/// A user in the Tink API.
public struct User {
    let accessToken: AccessToken

    /// The market to use.
    ///
    /// This is used by TinkLink when creating an anonymous user and when fetching providers.
    let market: Market

    /// The locale to use.
    let locale: Locale
}
