/// Defines how users should be managed by TinkLink.
public enum UserCreationStrategy {
    /// TinkLink will automatically create and manage an anonymous user.
    case automaticAnonymous
    /// TinkLink will handle the delegation and return the user created with a `UserContext`
    case delegation(String)
    /// Provide an existing user created with a `UserContext`.
    case existing(User)
}
