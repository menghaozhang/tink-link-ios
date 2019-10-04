struct AuthorizationResponse: Decodable {
    let code: AuthorizationCode
}

struct AuthorizationError: Error, LocalizedError, Decodable {
    let errorMessage: String
    let errorCode: String

    var errorDescription: String? {
        return errorMessage
    }
}
