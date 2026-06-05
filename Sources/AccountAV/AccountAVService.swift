import Foundation

@MainActor
public protocol AccountAVService {
    var isAvailable: Bool { get }
    var currentUser: AccountAVUser? { get }

    func restoreSession() async -> AccountAVSessionRestoreResult
    func getToken() async throws -> String?
    func signInWithApple() async throws
    func signInWithGoogle() async throws
    func signOut() async throws
}

public extension AccountAVService {
    func restoreSession() async -> AccountAVSessionRestoreResult {
        guard let user = currentUser else { return .signedOut }
        do {
            guard let token = try await getToken(), !token.isEmpty else {
                return .temporarilyUnavailable(user)
            }
            return .active(user)
        } catch {
            return .temporarilyUnavailable(user)
        }
    }
}
