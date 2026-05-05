// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AccountAV",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AccountAV",
            targets: ["AccountAV"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/clerk/clerk-ios", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AccountAV",
            dependencies: [
                .product(name: "ClerkKit", package: "clerk-ios")
            ]
        )
    ]
)
