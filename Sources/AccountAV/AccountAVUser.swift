import Foundation

public struct AccountAVUser: Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let emailAddress: String?

    public init(id: String, displayName: String, emailAddress: String?) {
        self.id = id
        self.displayName = displayName
        self.emailAddress = emailAddress
    }
}
