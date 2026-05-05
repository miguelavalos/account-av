import Foundation

public enum AccountAVError: LocalizedError, Sendable {
    case unavailable
    case missingSession

    public var errorDescription: String? {
        switch self {
        case .unavailable:
            "Account sign-in is not configured for this build."
        case .missingSession:
            "The account provider did not return an active session."
        }
    }
}
