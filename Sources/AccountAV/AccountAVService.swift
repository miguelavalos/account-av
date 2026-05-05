import Foundation

@MainActor
public protocol AccountAVService {
    var isAvailable: Bool { get }
    var currentUser: AccountAVUser? { get }

    func getToken() async throws -> String?
    func signInWithApple() async throws
    func signInWithGoogle() async throws
    func signOut() async throws
}
