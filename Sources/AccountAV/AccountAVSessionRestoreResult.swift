import Foundation

public enum AccountAVSessionRestoreResult: Equatable, Sendable {
    /// No persisted provider session is known after the provider is available.
    case signedOut
    /// The provider has an active session and provider metadata.
    case active(AccountAVUser)
    /// The provider, keychain, token refresh, or session metadata is not
    /// available right now. Product apps must not treat this as manual logout.
    case temporarilyUnavailable(AccountAVUser?)
    /// The provider explicitly invalidated the session. Product apps should
    /// still own product-account cleanup semantics.
    case invalidated
}

public enum AccountAVTokenError: LocalizedError, Equatable, Sendable {
    case unavailable
    case noPersistedSession
    case temporaryFailure(String)
    case invalidSession(String)
    case missingTokenAfterRestore

    public var errorDescription: String? {
        switch self {
        case .unavailable:
            "Account sign-in is not configured for this build."
        case .noPersistedSession:
            "No persisted account session is available."
        case .temporaryFailure:
            "The account session could not be refreshed right now."
        case .invalidSession:
            "The account session is no longer valid."
        case .missingTokenAfterRestore:
            "The account provider restored a session but did not return a token."
        }
    }
}
