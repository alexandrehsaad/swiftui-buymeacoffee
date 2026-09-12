// swift-tools-version:6.3

import PackageDescription

let package = Package(
    name: "swiftui-buymeacoffee",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
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
            path: "Sources",
            resources: [
                .process("BuyMeACoffee/Resources")
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
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing")

            ],
            exclude: [
                "__Snapshots__"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
