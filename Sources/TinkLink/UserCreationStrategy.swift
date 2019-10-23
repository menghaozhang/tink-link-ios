/// Defines how users should be managed by TinkLink.
public enum UserCreationStrategy {
    /// TinkLink will automatically create and manage an anonymous user.
    case automaticAnonymous
    /// Provide an existing user created with a `UserContext`.
    case existing(User)
}
