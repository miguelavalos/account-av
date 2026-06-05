import Foundation

public enum AccountAVSessionRestoreResult: Equatable, Sendable {
    case signedOut
    case active(AccountAVUser)
    case temporarilyUnavailable(AccountAVUser?)
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
