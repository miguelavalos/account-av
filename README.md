# Account AV

Shared Swift package for Account AV authentication in AV apps.

`AccountAV` wraps the Clerk native SDK behind a small app-facing API used by Tune AV, Series AV, and future AV apps. It centralizes the account flow so each app can keep its own product logic, branding, and access rules while sharing the same sign-in behavior.

Before validating signed native account workflows, read [AGENTS.md](AGENTS.md).
Those workflows are governed by private AVALSYS runbooks, and product apps must
resolve backend-owned identity through the internal Apps AV account contract.

## Features

- Clerk configuration helper
- Sign in with Apple
- Continue with Google through an OAuth flow that supports both sign-in and sign-up
- Defensive session activation and client refresh after native authentication
- Provider session user mapping through `AccountAVUser`
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

Apps that need explicit Clerk redirect or keychain settings can pass their
bundle identifier, keychain service, and access group:

```swift
AccountAVClerk.configureIfPossible(
    publishableKey: publishableKey,
    bundleIdentifier: Bundle.main.bundleIdentifier,
    keychainService: keychainService,
    keychainAccessGroup: keychainAccessGroup
)
```

Create a service:

```swift
let accountService = ClerkAccountAVService(
    publishableKeyProvider: { publishableKey },
    keychainServiceProvider: { keychainService },
    keychainAccessGroupProvider: { keychainAccessGroup },
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
operations such as `providerSessionUser`, `getToken()`, `signInWithApple()`,
`signInWithGoogle()`, and `signOut()`. The default implementation should wrap
`ClerkAccountAVService`.

`ClerkAccountAVService.providerSessionUser` is provider session metadata. Its `id` is
the provider subject, not the canonical Apps AV user id. Product apps must not
use that id for ownership, credits, subscriptions, Convex documents, D1 rows, R2
keys, purchase SDK customer ids, or analytics.

The canonical native identity flow is:

1. Use Account AV to sign in and obtain a provider token.
2. Call the platform API `/v1/me` with that token.
3. Publish and cache only the returned internal Apps AV user id.
4. If `/v1/me` fails, do not fall back to the provider subject.

Use the same launch and runtime pattern in every AV app:

- configure Account AV once at app startup with the app publishable key;
- provide the product fallback display name and logger subsystem;
- derive the redirect URI from the bundle identifier as
  `<bundle-id>://callback`;
- register the callback URL scheme as `$(PRODUCT_BUNDLE_IDENTIFIER)`;
- keep Sign in with Apple and Keychain entitlements aligned with the bundle id;
- add Associated Domains only when the product has a specific signed-runtime
  need, such as universal links, passkeys, or a verified Clerk Native API
  requirement for that app; when present, validate the exact entries in the
  product runtime/archive checks;
- after OAuth, read `providerSessionUser` only as provider session evidence, call
  `getToken()`, resolve `/v1/me`, then update local account state with the
  returned internal user;
- clear app-local account, entitlement, and credit state on sign-out.

Product apps should not call Clerk APIs directly, duplicate Account AV buttons,
or implement separate provider-specific account state machines.

Account AV does not define product branding. App icons, product marks, logo
lockups, native launch screens, splash artwork, onboarding artwork, Avi product
poses, paywall presentation, and footer/shell composition belong to Apps AV and
the individual product app. New product apps should follow the shared Apps AV
Apple product app pattern, then approve product-specific assets in that app's
own public/private handoff.

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
