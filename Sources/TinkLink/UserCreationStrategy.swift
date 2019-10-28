/// Defines how users should be managed by TinkLink.
public enum UserCreationStrategy {
    /// TinkLink will automatically create and manage an anonymous user.
    case automaticTemporary
    /// TinkLink will handle the delegation and return the permanent user.
    case automaticAuthorize(String)
    /// Provide an existing user created with a `UserContext`.
    case existing(User)
}
