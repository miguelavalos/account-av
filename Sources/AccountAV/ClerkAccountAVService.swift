import ClerkKit
import Foundation
import OSLog

@MainActor
public enum AccountAVClerk {
    public private(set) static var isConfigured = false

    public static func configureIfPossible(
        publishableKey: String,
        bundleIdentifier: String? = nil,
        keychainAccessGroup: String? = nil
    ) {
        guard !isConfigured else { return }

        let trimmedKey = publishableKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }

        let resolvedBundleIdentifier = bundleIdentifier ?? Bundle.main.bundleIdentifier ?? ""
        let options = Clerk.Options(
            keychainConfig: .init(
                service: resolvedBundleIdentifier,
                accessGroup: keychainAccessGroup
            ),
            redirectConfig: .init(
                redirectUrl: "\(resolvedBundleIdentifier)://callback",
                callbackUrlScheme: resolvedBundleIdentifier
            )
        )
        Clerk.configure(publishableKey: trimmedKey, options: options)
        isConfigured = true
    }
}

@MainActor
public struct ClerkAccountAVService: AccountAVService {
    private let publishableKeyProvider: () -> String
    private let fallbackDisplayName: String
    private let authLogger: Logger

    public init(
        publishableKeyProvider: @escaping () -> String,
        fallbackDisplayName: String,
        loggerSubsystem: String = "com.avalsys.accountav"
    ) {
        self.publishableKeyProvider = publishableKeyProvider
        self.fallbackDisplayName = fallbackDisplayName
        self.authLogger = Logger(subsystem: loggerSubsystem, category: "auth")
    }

    public var isAvailable: Bool {
        !publishableKeyProvider().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var currentUser: AccountAVUser? {
        guard AccountAVClerk.isConfigured else { return nil }
        guard isAvailable, let user = Clerk.shared.user else { return nil }
        return accountUser(from: user)
    }

    public func restoreSession() async -> AccountAVSessionRestoreResult {
        guard isAvailable else { return .signedOut }
        ensureClerkIsConfigured()

        do {
            if let token = try await activeSessionToken(), !token.isEmpty {
                return currentUser.map(AccountAVSessionRestoreResult.active) ?? .signedOut
            }
        } catch {
            return .temporarilyUnavailable(currentUser)
        }

        do {
            try await ensureClerkIsReady()
        } catch {
            return .temporarilyUnavailable(currentUser)
        }

        do {
            if let token = try await activeSessionToken(), !token.isEmpty {
                return currentUser.map(AccountAVSessionRestoreResult.active) ?? .signedOut
            }
        } catch {
            return .temporarilyUnavailable(currentUser)
        }

        guard let fallbackSession = Clerk.shared.auth.sessions.first else {
            authLogger.debug("No persisted Clerk session available during restore")
            return .signedOut
        }

        do {
            authLogger.info("Activating persisted Clerk session during restore")
            try await Clerk.shared.auth.setActive(sessionId: fallbackSession.id)
            _ = try? await Clerk.shared.refreshClient()
            if let token = try await activeSessionToken(), !token.isEmpty {
                return currentUser.map(AccountAVSessionRestoreResult.active) ?? .signedOut
            }
            return .temporarilyUnavailable(currentUser)
        } catch {
            return .temporarilyUnavailable(currentUser)
        }
    }

    private func accountUser(from user: User) -> AccountAVUser {
        let displayName = [user.firstName, user.lastName]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " ")

        return AccountAVUser(
            id: user.id,
            displayName: displayName.isEmpty ? fallbackDisplayName : displayName,
            emailAddress: user.primaryEmailAddress?.emailAddress
        )
    }

    public func getToken() async throws -> String? {
        guard isAvailable else { return nil }
        ensureClerkIsConfigured()

        if let token = try await activeSessionToken(), !token.isEmpty {
            return token
        }

        try await ensureClerkIsReady()
        if let token = try await activeSessionToken(), !token.isEmpty {
            return token
        }

        guard let fallbackSession = Clerk.shared.auth.sessions.first else {
            authLogger.debug("No active Clerk session available")
            return nil
        }

        authLogger.info("Activating persisted Clerk session before requesting token")
        try await Clerk.shared.auth.setActive(sessionId: fallbackSession.id)
        _ = try? await Clerk.shared.refreshClient()
        return try await activeSessionToken()
    }

    public func signInWithApple() async throws {
        guard isAvailable else { throw AccountAVError.unavailable }
        ensureClerkIsConfigured()
        try await ensureClerkIsReady()
        authLogger.info("Starting Apple sign-in")
        #if os(iOS)
        let result = try await Clerk.shared.auth.signInWithApple()
        #else
        let result = try await Clerk.shared.auth.signInWithOAuth(provider: .apple)
        #endif
        authLogger.info("Apple sign-in returned transfer result")
        try await activateSession(from: result)
    }

    public func signInWithGoogle() async throws {
        guard isAvailable else { throw AccountAVError.unavailable }
        ensureClerkIsConfigured()
        try await ensureClerkIsReady()
        authLogger.info("Starting Google sign-in")
        let result = try await Clerk.shared.auth.signInWithOAuth(provider: .google)
        authLogger.info("Google sign-in returned transfer result")
        try await activateSession(from: result)
    }

    public func signOut() async throws {
        guard isAvailable else { return }
        guard AccountAVClerk.isConfigured else { return }
        try await Clerk.shared.auth.signOut()
    }

    private func ensureClerkIsConfigured() {
        AccountAVClerk.configureIfPossible(
            publishableKey: publishableKeyProvider(),
            bundleIdentifier: Bundle.main.bundleIdentifier
        )
    }

    private func activateSession(from result: TransferFlowResult) async throws {
        let createdSessionId: String?
        let statusDescription: String

        switch result {
        case .signIn(let signIn):
            createdSessionId = signIn.createdSessionId
            statusDescription = String(describing: signIn.status)
        case .signUp(let signUp):
            createdSessionId = signUp.createdSessionId
            statusDescription = String(describing: signUp.status)
        }

        authLogger.info("Transfer flow status: \(statusDescription, privacy: .public)")

        guard let createdSessionId, !createdSessionId.isEmpty else {
            _ = try? await Clerk.shared.refreshClient()
            if Clerk.shared.session != nil {
                authLogger.info("Clerk session active after client refresh")
                return
            }

            authLogger.error("Transfer flow finished without a created session id")
            throw AccountAVError.missingSession
        }

        authLogger.info("Activating Clerk session")
        try await Clerk.shared.auth.setActive(sessionId: createdSessionId)
        try await Clerk.shared.refreshClient()
        authLogger.info("Clerk session activated")
    }

    private func ensureClerkIsReady() async throws {
        guard !Clerk.shared.isLoaded else { return }
        authLogger.info("Refreshing Clerk client before sign-in")
        async let environment = Clerk.shared.refreshEnvironment()
        async let client = Clerk.shared.refreshClient()
        _ = try await (environment, client)
    }

    private func activeSessionToken() async throws -> String? {
        try await Clerk.shared.session?.getToken(.init(skipCache: true))
    }
}
