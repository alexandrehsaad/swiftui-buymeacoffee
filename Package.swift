// swift-tools-version:5.7

import PackageDescription

let package = Package(
	name: "swiftui-buymeacoffee",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v15),
		.macCatalyst(.v15),
		.macOS(.v12)
	],
	products: [
		.library(name: "BuyMeACoffee", targets: ["BuyMeACoffee"])
	],
	dependencies: [
		.package(url: "https://github.com/alexandrehsaad/swift-contributors-plugin", branch: "main"),
		.package(url: "https://github.com/apple/swift-docc-plugin.git", .upToNextMinor(from: "1.0.0"))
	],
	targets: [
		.target(name: "BuyMeACoffee", dependencies: [], path: "Sources", resources: [
			.process("BuyMeACoffee/Resources")
		])
	],
	swiftLanguageVersions: [.v5]
)
