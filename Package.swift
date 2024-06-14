// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SmallCharacterModel",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SmallCharacterModel",
            targets: ["SmallCharacterModel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SmallCharacterModel",
            dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture")]
        ),
        .testTarget(
            name: "SmallCharacterModelTests",
            dependencies: ["SmallCharacterModel"],
            resources: [
                .copy("Resources/test-set.txt"),
                .copy("Resources/shakespeare.txt"),
                .copy("Resources/pirate-terms.txt")
            ])
    ]
)
