// swift-tools-version:6.3

import PackageDescription

let package = Package(
    name: "swiftui-buymeacoffee",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
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
        )
    ],
    targets: [
        .plugin(
            name: "BuyMeACoffeeSnapshotsPlugin",
            capability: .command(
                intent: .custom(
                    verb: "record-snapshots",
                    description: "Re-record and verify the Buy Me a Coffee iOS snapshots"
                ),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "Replace the iOS snapshot reference images"
                    ),
                    .allowNetworkConnections(
                        scope: .all(),
                        reason: "Resolve the snapshot host's Swift package dependencies"
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
            name: "BuyMeACoffeeTests",
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
