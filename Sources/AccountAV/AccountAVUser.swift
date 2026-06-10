import Foundation

public struct AccountAVUser: Equatable, Sendable {
    /// Provider subject id, such as a Clerk user id.
    ///
    /// This is provider session metadata only. Product apps must resolve and
    /// cache their internal Apps AV user through `/v1/me` before using an id for
    /// ownership, purchases, analytics, Convex, D1, or R2 state.
    public let id: String
    public let displayName: String
    public let emailAddress: String?

    public init(id: String, displayName: String, emailAddress: String?) {
        self.id = id
        self.displayName = displayName
        self.emailAddress = emailAddress
    }
}
