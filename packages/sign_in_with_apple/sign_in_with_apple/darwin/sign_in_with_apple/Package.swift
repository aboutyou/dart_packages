// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sign_in_with_apple",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "sign-in-with-apple", targets: ["sign_in_with_apple"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "sign_in_with_apple",
            dependencies: [],
            resources: []
        )
    ]
)
