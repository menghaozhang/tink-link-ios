import Foundation

/// An object that you use to authorize for a user with requested scopes.
public final class AuthenticationContext {
    private var tinkLink: TinkLink
    private var authenticationService: AuthenticationService
    private var retryCancellable: RetryCancellable?

    /// Creates a context to authorize for an authorization code for a user with requested scopes.
    /// - Parameter tinkLink: TinkLink instance, will use the shared instance if nothing is provided.
    /// - Parameter accessToken: `AccessToken` that will be used for authorizing scope with the Tink API.
    public init(tinkLink: TinkLink = .shared, accessToken: AccessToken) {
        self.tinkLink = tinkLink
        self.authenticationService = AuthenticationService(tinkLink: tinkLink, accessToken: accessToken)
    }

    /// Creates an authorization code with the requested scopes for the current user
    ///
    /// Once you have received the authorization code, you can exchange it for an access token on your backend and use the access token to access the user's data.
    /// Exchanging the authorization code for an access token requires the use of the client secret associated with your client identifier.
    ///
    /// - Parameter scope: A TinkLinkScope list of OAuth scopes to be requested.
    ///                    The Scope array should never be empty.
    /// - Parameter completion: The block to execute when the authorization is complete.
    /// - Parameter result: Represents either an authorization code if authorization was successful or an error if authorization failed.
    @discardableResult
    public func authorize(scope: TinkLink.Scope, completion: @escaping (_ result: Result<AuthorizationCode, Error>) -> Void) -> Cancellable? {

        return authenticationService.authorize(redirectURI: tinkLink.configuration.redirectURI, scope: scope) { (result) in
            completion(result.map({ $0.code }))
        }
    }
}
