import ClerkKit
import Foundation
import OSLog

@MainActor
public enum AccountAVClerk {
    public static func configureIfPossible(
        publishableKey: String,
        bundleIdentifier: String? = nil,
        keychainAccessGroup: String? = nil
    ) {
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
        guard isAvailable, let user = Clerk.shared.user else { return nil }
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

        if let token = try await activeSessionToken(), !token.isEmpty {
            return token
        }

        try await ensureClerkIsReady()
        if let token = try await activeSessionToken(), !token.isEmpty {
            return token
        }

        guard let fallbackSession = Clerk.shared.auth.sessions.first else {
            authLogger.error("Unable to find an active Clerk session")
            return nil
        }

        authLogger.info("Activating persisted Clerk session before requesting token")
        try await Clerk.shared.auth.setActive(sessionId: fallbackSession.id)
        _ = try? await Clerk.shared.refreshClient()
        return try await activeSessionToken()
    }

    public func signInWithApple() async throws {
        guard isAvailable else { throw AccountAVError.unavailable }
        try await ensureClerkIsReady()
        authLogger.info("Starting Apple sign-in")
        let result = try await Clerk.shared.auth.signInWithOAuth(provider: .apple)
        authLogger.info("Apple sign-in returned transfer result")
        try await activateSession(from: result)
    }

    public func signInWithGoogle() async throws {
        guard isAvailable else { throw AccountAVError.unavailable }
        try await ensureClerkIsReady()
        authLogger.info("Starting Google sign-in")
        let result = try await Clerk.shared.auth.signInWithOAuth(provider: .google)
        authLogger.info("Google sign-in returned transfer result")
        try await activateSession(from: result)
    }

    public func signOut() async throws {
        guard isAvailable else { return }
        try await Clerk.shared.auth.signOut()
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
