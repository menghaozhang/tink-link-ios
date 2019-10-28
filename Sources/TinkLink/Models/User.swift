/// A user in the Tink API.
public struct User {
    let accessToken: AccessToken
}

extension User {
    public init(accessToken: String) {
        self.accessToken = AccessToken(accessToken)
    }
}
