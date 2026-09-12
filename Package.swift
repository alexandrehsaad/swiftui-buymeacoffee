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
    ],
    targets: [
        .target(
            name: "BuyMeACoffee",
            path: "Sources",
            resources: [
                .process("BuyMeACoffee/Resources")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
