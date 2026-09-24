// swift-tools-version:6.3

import PackageDescription

let package = Package(
    name: "swiftui-buymeacoffee",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BuyMeACoffeeSnapshotTesting",
            targets: ["BuyMeACoffeeSnapshotTesting"]
        ),
        .library(
            name: "BuyMeACoffee",
            targets: [
                "BuyMeACoffee"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.19.4"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin.git",
            from: "1.5.0"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-format.git",
            from: "603.0.0"
        )
    ],
    targets: [
        .plugin(
            name: "BuyMeACoffeeLinterPlugin",
            capability: .command(
                intent: .custom(
                    verb: "lint",
                    description: "Lint all Swift source files"
                )
            ),
            dependencies: [
                .product(
                    name: "swift-format",
                    package: "swift-format"
                )
            ]
        ),
        .plugin(
            name: "BuyMeACoffeeSnapshotsPlugin",
            capability: .command(
                intent: .custom(
                    verb: "record-snapshots",
                    description: "Re-record and verify the snapshots"
                ),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "Replace the snapshot reference images"
                    ),
                    .allowNetworkConnections(
                        scope: .all(),
                        reason: "Resolve the test host's Swift package dependencies"
                    )
                ]
            )
        ),
        .target(
            name: "BuyMeACoffee",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "BuyMeACoffeeSnapshotTesting",
            dependencies: [
                "BuyMeACoffee",
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing"
                )
            ]
        ),
        .testTarget(
            name: "BuyMeACoffeeUnitTests",
            dependencies: [
                "BuyMeACoffee"
            ]
        ),
        .testTarget(
            name: "BuyMeACoffeeSnapshotTests",
            dependencies: [
                "BuyMeACoffee",
                "BuyMeACoffeeSnapshotTesting"
            ],
            exclude: [
                "__Snapshots__"
            ]
        ),
        .testTarget(
            name: "RepositorySnapshotTests",
            dependencies: [
                "BuyMeACoffee",
                "BuyMeACoffeeSnapshotTesting"
            ],
            exclude: [
                "__Snapshots__"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
