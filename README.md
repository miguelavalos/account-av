# Account AV

Shared Swift package for Account AV authentication in AV apps.

`AccountAV` wraps the Clerk native SDK behind a small app-facing API used by Tune AV, Series AV, and future AV apps. It centralizes the account flow so each app can keep its own product logic, branding, and access rules while sharing the same sign-in behavior.

## Features

- Clerk configuration helper
- Sign in with Apple
- Continue with Google through an OAuth flow that supports both sign-in and sign-up
- Defensive session activation and client refresh after native authentication
- Current user mapping through `AccountAVUser`
- Session token retrieval
- Sign out

## Installation

During local development, add the package by path:

```swift
.package(path: "../account-av")
```

For app repositories that live next to this package, use the relative path that matches the app project. For example, from `public/series-av/apps/ios` the package path is `../../../account-av`.

When publishing a stable release, prefer pinning this package by Git tag.

## Usage

Configure Clerk at app launch:

```swift
import AccountAV

AccountAVClerk.configureIfPossible(publishableKey: publishableKey)
```

Apps that need explicit Clerk redirect or keychain settings can pass their bundle identifier and access group:

```swift
AccountAVClerk.configureIfPossible(
    publishableKey: publishableKey,
    bundleIdentifier: Bundle.main.bundleIdentifier,
    keychainAccessGroup: keychainAccessGroup
)
```

Create a service:

```swift
let accountService = ClerkAccountAVService(
    publishableKeyProvider: { publishableKey },
    fallbackDisplayName: "Account AV user",
    loggerSubsystem: "com.example.app"
)
```

Use it from the app account layer:

```swift
try await accountService.signInWithApple()
try await accountService.signInWithGoogle()
let token = try await accountService.getToken()
try await accountService.signOut()
```

## Product App Contract

Product apps must treat Clerk as an Account AV implementation detail. App code
should depend on an app-local account service protocol with provider-neutral
operations such as `currentUser`, `getToken()`, `signInWithApple()`,
`signInWithGoogle()`, and `signOut()`. The default implementation should wrap
`ClerkAccountAVService`.

Use the same launch and runtime pattern in every AV app:

- configure Account AV once at app startup with the app publishable key;
- provide the product fallback display name and logger subsystem;
- derive the redirect URI from the bundle identifier as
  `<bundle-id>://callback`;
- register the callback URL scheme as `$(PRODUCT_BUNDLE_IDENTIFIER)`;
- keep Sign in with Apple and Keychain entitlements aligned with the bundle id;
- after OAuth, read `currentUser`, call `getToken()` if needed, then read
  `currentUser` again before resolving local account state;
- clear app-local account, entitlement, and credit state on sign-out.

Product apps should not call Clerk APIs directly, duplicate Account AV buttons,
or implement separate provider-specific account state machines.

Unsigned simulator builds are suitable for compile-only checks, but they are not
valid Account AV sign-in smokes. Apple, Google, token, Keychain, and account
state tests need a signed simulator install so Keychain entitlements are
available.

## Public Safety

This package must not contain app secrets, publishable keys, private API URLs, user emails, provisioning data, or local machine paths. Apps provide their own configuration at runtime through their bundle settings or environment-specific build configuration.

## Requirements

- iOS 18+
- macOS 14+ for SwiftPM package resolution
- Swift 6
- Clerk iOS SDK 1.x
