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

## Public Safety

This package must not contain app secrets, publishable keys, private API URLs, user emails, provisioning data, or local machine paths. Apps provide their own configuration at runtime through their bundle settings or environment-specific build configuration.

## Requirements

- iOS 18+
- macOS 14+ for SwiftPM package resolution
- Swift 6
- Clerk iOS SDK 1.x
