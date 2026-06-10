import AccountAV
import XCTest

@MainActor
private struct StubAccountAVService: AccountAVService {
    var isAvailable = true
    var providerSessionUser: AccountAVUser?
    var tokenResult: Result<String?, Error> = .success(nil)

    func getToken() async throws -> String? {
        try tokenResult.get()
    }

    func signInWithApple() async throws {}
    func signInWithGoogle() async throws {}
    func signOut() async throws {}
}

private enum StubTokenError: Error {
    case refreshFailed
}

final class AccountAVServiceRestoreTests: XCTestCase {
    @MainActor
    func testRestoreWithProviderUserAndTokenIsActive() async {
        let user = AccountAVUser(
            id: "provider-user-id",
            displayName: "Provider User",
            emailAddress: "provider@example.com"
        )
        let service = StubAccountAVService(
            providerSessionUser: user,
            tokenResult: .success("provider-token")
        )

        let result = await service.restoreSession()

        XCTAssertEqual(result, .active(user))
    }

    @MainActor
    func testRestoreWithProviderUserButMissingTokenIsTemporarilyUnavailable() async {
        let user = AccountAVUser(
            id: "provider-user-id",
            displayName: "Provider User",
            emailAddress: nil
        )
        let service = StubAccountAVService(
            providerSessionUser: user,
            tokenResult: .success(nil)
        )

        let result = await service.restoreSession()

        XCTAssertEqual(result, .temporarilyUnavailable(user))
    }

    @MainActor
    func testRestoreWithProviderUserButTokenErrorIsTemporarilyUnavailable() async {
        let user = AccountAVUser(
            id: "provider-user-id",
            displayName: "Provider User",
            emailAddress: nil
        )
        let service = StubAccountAVService(
            providerSessionUser: user,
            tokenResult: .failure(StubTokenError.refreshFailed)
        )

        let result = await service.restoreSession()

        XCTAssertEqual(result, .temporarilyUnavailable(user))
    }

    @MainActor
    func testRestoreWithNoProviderUserButTokenUncertaintyIsNotSignedOut() async {
        let service = StubAccountAVService(
            providerSessionUser: nil,
            tokenResult: .failure(StubTokenError.refreshFailed)
        )

        let result = await service.restoreSession()

        XCTAssertEqual(result, .temporarilyUnavailable(nil))
    }
}
