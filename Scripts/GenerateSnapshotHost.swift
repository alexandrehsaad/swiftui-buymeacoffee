// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

// Generates disposable Xcode scaffolding for iOS snapshot tests.
import Foundation

// MARK: - GeneratedProject

/// Serialized project contents and target identifiers needed to create its scheme.
private struct GeneratedProject {
    /// Complete XML property list for the generated Xcode project.
    let data: Data

    /// Project identifier of the application target.
    let applicationID: String

    /// Project identifier of the hosted test target.
    let testsID: String
}

// MARK: - ResolvedDependency

/// SnapshotTesting's repository and exact commit from the package lockfile.
private struct ResolvedDependency {
    /// Repository URL recorded by SwiftPM.
    let location: String

    /// Resolved commit used by both the package and generated host.
    let revision: String
}

// MARK: - SnapshotHost

/// Generates a disposable host application, project, and comparison scheme for iOS snapshots.
private struct SnapshotHost {
    /// Repository containing the package manifest and original snapshot test sources.
    let packageDirectory: URL

    /// Name shared by the generated test target and recorder filters.
    let testName: String

    /// File manager used to discover sources and write generated files.
    private let manager = FileManager.default

    /// Disposable directory containing the application source and project.
    private var hostDirectory: URL {
        packageDirectory.appendingPathComponent(".build/snapshots/Host")
    }

    /// Xcode project consumed by the recording script and CI.
    private var projectDirectory: URL {
        hostDirectory.appendingPathComponent("SnapshotHost.xcodeproj")
    }

    /// Creates the host while preserving unchanged files for incremental builds.
    ///
    /// - Throws: Source discovery, dependency parsing, project serialization, or file-writing errors.
    func generate() throws {
        let sources = try testSources()
        let dependency = try resolvedDependency()
        let project = try SnapshotProjectBuilder().build(
            root: packageDirectory,
            sources: sources,
            dependency: dependency,
            testName: self.testName
        )
        try write(project.data, to: projectDirectory.appendingPathComponent("project.pbxproj"))
        try writeApplication()
        try write(
            comparisonScheme(for: project),
            to: projectDirectory.appendingPathComponent("xcshareddata/xcschemes/SnapshotHost.xcscheme")
        )
        print("Generated snapshot host: \(projectDirectory.path)")
    }

    /// Finds immediate Swift test files in stable path order without copying their contents.
    ///
    /// - Returns: Absolute source URLs, keeping snapshot paths anchored in the repository.
    /// - Throws: An error if the test directory cannot be read.
    private func testSources() throws -> [URL] {
        // Directory containing the original iOS snapshot test sources.
        let testDirectory = packageDirectory.appendingPathComponent("Tests/\(self.testName)")

        // Immediate Swift source files, sorted by path to make project generation deterministic.
        let sources = try manager.contentsOfDirectory(at: testDirectory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }.sorted { $0.path < $1.path }

        return sources
    }

    /// Reads SnapshotTesting's pin instead of maintaining a second dependency version.
    ///
    /// - Returns: The locked repository URL and revision.
    /// - Throws: File or JSON errors, or a diagnostic if the lockfile lacks the required pin.
    private func resolvedDependency() throws -> ResolvedDependency {
        // Resolved package dependency data used to select the existing SnapshotTesting revision.
        let lockData = try Data(contentsOf: packageDirectory.appendingPathComponent("Package.resolved"))

        // Read the repository URL and commit from the lockfile instead of maintaining a second dependency version.
        guard let lock = try JSONSerialization.jsonObject(with: lockData) as? [String: Any],
            let pins = lock["pins"] as? [[String: Any]],
            let pin = pins.first(where: { $0["identity"] as? String == "swift-snapshot-testing" }),
            let location = pin["location"] as? String,
            let state = pin["state"] as? [String: Any],
            let revision = state["revision"] as? String
        else {
            throw NSError(
                domain: "SnapshotHost", code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Package.resolved must contain swift-snapshot-testing. Resolve package dependencies first."
                ])
        }

        return ResolvedDependency(location: location, revision: revision)
    }

    /// Writes the minimal SwiftUI application that supplies a window for glass rendering.
    ///
    /// - Throws: Directory creation or file-writing errors.
    private func writeApplication() throws {
        // A real application window lets the snapshot tests capture system visual effects.
        try write(
            Data(
                ("import SwiftUI\n"
                    + "@main struct SnapshotHostApp: App { var body: some Scene { WindowGroup { Color.clear } } }\n")
                    .utf8),
            to: hostDirectory.appendingPathComponent("SnapshotHostApp.swift"))
    }

    /// Creates the comparison scheme; recording is enabled separately in disposable test-run files.
    ///
    /// - Parameter project: Target identifiers produced by the project builder.
    /// - Returns: UTF-8 XML describing the shared scheme.
    private func comparisonScheme(for project: GeneratedProject) -> Data {
        // Scheme buildable reference identifying the host application target.
        let appRef = reference(project.applicationID, "SnapshotHost", "SnapshotHost.app")

        // Scheme buildable reference identifying the snapshot test target.
        let testRef = reference(project.testsID, self.testName, "\(self.testName).xctest")

        // Shared comparison-only scheme; the recorder enables recording in disposable test-run configurations.
        let scheme = """
            <?xml version="1.0" encoding="UTF-8"?>
            <Scheme version="1.3">
            <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries>
            <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="NO"\
             buildForArchiving="NO" buildForAnalyzing="YES">\(appRef)</BuildActionEntry>
            <BuildActionEntry buildForTesting="YES" buildForRunning="NO" buildForProfiling="NO"\
             buildForArchiving="NO" buildForAnalyzing="YES">\(testRef)</BuildActionEntry>
            </BuildActionEntries></BuildAction>
            <TestAction buildConfiguration="Debug" shouldUseLaunchSchemeArgsEnv="NO" language="en" region="US">
            <Testables><TestableReference skipped="NO" parallelizable="NO">\(testRef)</TestableReference></Testables>
            <EnvironmentVariables>\
            <EnvironmentVariable key="SNAPSHOT_TESTING_RECORD" value="never" isEnabled="YES"/></EnvironmentVariables>
            </TestAction>
            </Scheme>
            """

        return Data(scheme.utf8)
    }

    /// Creates a scheme reference to a target in the generated project.
    ///
    /// The supplied values are internal identifiers and names that contain no XML-sensitive characters.
    /// - Parameters:
    ///   - id: Identifier of the native target in the project object table.
    ///   - name: Target name displayed by Xcode.
    ///   - product: Build-product filename, including its bundle extension.
    /// - Returns: An XML buildable reference for use in the scheme.
    private func reference(_ id: String, _ name: String, _ product: String) -> String {
        "<BuildableReference BuildableIdentifier=\"primary\" BlueprintIdentifier=\"\(id)\""
            + " BuildableName=\"\(product)\" BlueprintName=\"\(name)\""
            + " ReferencedContainer=\"container:SnapshotHost.xcodeproj\"/>"
    }

    /// Writes a generated file only when its contents differ, preserving incremental build inputs.
    ///
    /// - Parameters:
    ///   - data: Complete file contents to write atomically.
    ///   - url: Destination whose parent directories are created when necessary.
    /// - Throws: Directory creation or file-writing errors.
    private func write(_ data: Data, to url: URL) throws {
        try manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if (try? Data(contentsOf: url)) != data { try data.write(to: url, options: .atomic) }
    }
}

// MARK: - SnapshotProjectBuilder

/// Owns Xcode's object graph while constructing one application and its hosted test target.
///
/// A new builder is created for each generation so identifiers remain stable between runs.
private final class SnapshotProjectBuilder {
    /// Project object table, keyed by the identifiers returned by `object(_:_:)`.
    private var objects: [String: Any] = [:]

    /// Counter used to assign stable identifiers when objects are created in the same order.
    private var nextID = 0

    /// Adds a typed object to the project table and returns its generated identifier.
    ///
    /// - Parameters:
    ///   - isa: Xcode project object type, such as `PBXNativeTarget`.
    ///   - values: Fields for the object; the explicit type overrides any supplied `isa` field.
    /// - Returns: A unique, 24-digit hexadecimal project identifier.
    private func object(_ isa: String, _ values: [String: Any]) -> String {
        nextID += 1
        let id = String(format: "%024X", nextID)
        objects[id] = values.merging(["isa": isa]) { _, new in new }
        return id
    }

    /// Creates Debug and Release configurations with identical settings for snapshot builds.
    ///
    /// - Parameter settings: Build settings applied to both configurations.
    /// - Returns: The identifier of a configuration list whose default is Debug.
    private func configurations(_ settings: [String: Any]) -> String {
        let configs = ["Debug", "Release"].map {
            object(
                "XCBuildConfiguration",
                ["name": $0, "buildSettings": settings]
            )
        }
        return object(
            "XCConfigurationList",
            [
                "buildConfigurations": configs,
                "defaultConfigurationIsVisible": "0", "defaultConfigurationName": "Debug",
            ])
    }

    /// Creates a build phase that participates in ordinary builds.
    ///
    /// - Parameters:
    ///   - isa: Build phase type, such as `PBXSourcesBuildPhase`.
    ///   - files: Build-file object identifiers included in the phase; defaults to an empty phase.
    /// - Returns: The new build phase identifier.
    private func phase(_ isa: String, _ files: [String] = []) -> String {
        object(
            isa,
            [
                "buildActionMask": "2147483647",
                "files": files,
                "runOnlyForDeploymentPostprocessing": "0",
            ]
        )
    }

    /// Shared simulator build settings; iOS 26 enables glass styles and testability exposes internal declarations.
    private let common: [String: Any] = [
        "CODE_SIGNING_ALLOWED": "NO",
        "ENABLE_TESTABILITY": "YES",
        "GENERATE_INFOPLIST_FILE": "YES",
        "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
        "SDKROOT": "iphoneos",
        "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
        "SWIFT_VERSION": "6.0",
        "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "ONLY_ACTIVE_ARCH": "YES",
        "TARGETED_DEVICE_FAMILY": "1,2",
        "PRODUCT_NAME": "$(TARGET_NAME)",
    ]

    /// Creates configurations by applying target-specific overrides to the shared settings.
    ///
    /// - Parameter extra: Settings that replace matching shared values or add target-specific values.
    /// - Returns: The target's configuration list identifier.
    private func settings(_ extra: [String: Any]) -> String {
        configurations(common.merging(extra) { _, new in new })
    }

    /// Constructs the Xcode object graph and serializes it for the host writer.
    ///
    /// - Parameters:
    ///   - root: Absolute repository URL used by the local package reference.
    ///   - sources: Original snapshot test files in deterministic order.
    ///   - dependency: SnapshotTesting repository and revision from the package lockfile.
    /// - Returns: Serialized project data and the target identifiers required by its scheme.
    /// - Throws: Property-list serialization errors.
    func build(
        root: URL,
        sources: [URL],
        dependency: ResolvedDependency,
        testName: String
    ) throws -> GeneratedProject {
        // Project reference to the generated SwiftUI host application source.
        let appSource = object(
            "PBXFileReference",
            [
                "path": "SnapshotHostApp.swift",
                "sourceTree": "<group>",
                "lastKnownFileType": "sourcecode.swift",
            ]
        )

        // Absolute references to original test files, preserving their snapshot reference locations.
        let testSources = sources.map {
            object(
                "PBXFileReference",
                [
                    "path": $0.path,
                    "sourceTree": "<absolute>",
                    "lastKnownFileType": "sourcecode.swift",
                ]
            )
        }

        // Build-product reference for the host application bundle.
        let appProduct = object(
            "PBXFileReference",
            [
                "path": "SnapshotHost.app",
                "sourceTree": "BUILT_PRODUCTS_DIR",
                "explicitFileType": "wrapper.application",
            ]
        )
        
        // Build-product reference for the hosted test bundle.
        let testProduct = object(
            "PBXFileReference",
            [
                "path": "\(testName).xctest",
                "sourceTree": "BUILT_PRODUCTS_DIR",
                "explicitFileType": "wrapper.cfbundle",
            ]
        )

        // Project navigator group containing the generated build products.
        let products = object(
            "PBXGroup",
            [
                "name": "Products",
                "sourceTree": "<group>",
                "children": [appProduct, testProduct],
            ]
        )

        // Root navigator group containing application source, test sources, and products.
        let group = object(
            "PBXGroup",
            [
                "sourceTree": "<group>",
                "children": [appSource] + testSources + [products],
            ]
        )

        // Local package reference pointing to the repository being tested.
        let package = object("XCLocalSwiftPackageReference", ["relativePath": root.path])

        // Remote dependency pinned to the same SnapshotTesting commit as the package lockfile.
        let snapshotPackage = object(
            "XCRemoteSwiftPackageReference",
            [
                "repositoryURL": dependency.location,
                "requirement": [
                    "kind": "revision",
                    "revision": dependency.revision,
                ],
            ]
        )

        // Package product references linked into the hosted test target.
        let dependencies = [
            (package, "BuyMeACoffee"),
            (package, "BuyMeACoffeeSnapshotTesting"),
            (snapshotPackage, "SnapshotTesting"),
        ].map {
            object("XCSwiftPackageProductDependency", ["package": $0.0, "productName": $0.1])
        }

        // Native application target providing the window required for glass snapshots.
        let app = object(
            "PBXNativeTarget",
            [
                "name": "SnapshotHost",
                "productName": "SnapshotHost",
                "productType": "com.apple.product-type.application",
                "productReference": appProduct,
                "buildConfigurationList": settings([
                    "PRODUCT_BUNDLE_IDENTIFIER": "org.buymeacoffee.SnapshotHost",
                    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                    "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                ]),
                "buildPhases": [
                    phase("PBXSourcesBuildPhase", [object("PBXBuildFile", ["fileRef": appSource])]),
                    phase("PBXFrameworksBuildPhase"),
                    phase("PBXResourcesBuildPhase"),
                ],
                "buildRules": [],
                "dependencies": [],
            ]
        )

        // Native test target that loads into the host application and compiles the original test sources.
        let tests = object(
            "PBXNativeTarget",
            [
                "name": testName,
                "productName": testName,
                "productType": "com.apple.product-type.bundle.unit-test",
                "productReference": testProduct,
                "buildConfigurationList": settings([
                    "PRODUCT_BUNDLE_IDENTIFIER": "org.buymeacoffee.\(testName)",
                    // These test sources belong to the local package and use its package-scoped helpers.
                    "OTHER_SWIFT_FLAGS": "$(inherited) -package-name swiftui_buymeacoffee",
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/SnapshotHost.app/SnapshotHost", "BUNDLE_LOADER": "$(TEST_HOST)",
                ]),
                "buildPhases": [
                    phase("PBXSourcesBuildPhase", testSources.map { object("PBXBuildFile", ["fileRef": $0]) }),
                    phase("PBXFrameworksBuildPhase", dependencies.map { object("PBXBuildFile", ["productRef": $0]) }),
                    phase("PBXResourcesBuildPhase"),
                ],
                "buildRules": [],
                "dependencies": [object("PBXTargetDependency", ["target": app])],
                "packageProductDependencies": dependencies,
            ]
        )

        // Root project object connecting targets, package dependencies, groups, and build settings.
        let projectID = object(
            "PBXProject",
            [
                "buildConfigurationList": configurations(common),
                "compatibilityVersion": "Xcode 14.0",
                "developmentRegion": "en",
                "knownRegions": ["en", "Base"],
                "mainGroup": group,
                "productRefGroup": products,
                "projectDirPath": "",
                "projectRoot": "",
                "targets": [app, tests],
                "packageReferences": [package, snapshotPackage],
                "attributes": ["TargetAttributes": [tests: ["TestTargetID": app]]],
            ]
        )

        // Xcode expects string values for project format versions, even in an XML property list.
        let data = try PropertyListSerialization.data(
            fromPropertyList: [
                "archiveVersion": "1",
                "objectVersion": "56",
                "classes": [:],
                "objects": objects,
                "rootObject": projectID,
            ],
            format: .xml,
            options: 0
        )
        
        return GeneratedProject(data: data, applicationID: app, testsID: tests)
    }
}

// MARK: - Generation

// Resolve paths from the script so the caller's working directory does not affect generation.
let arguments: Array<String> = Array(CommandLine.arguments.dropFirst())
let testName: String
switch arguments {
case []:
    testName = "BuyMeACoffeeSnapshotTests"
case ["--repository-snapshots"]:
    testName = "RepositorySnapshotTests"
case ["--unit-tests"]:
    testName = "BuyMeACoffeeTests"
default:
    throw NSError(
        domain: "SnapshotHost",
        code: 2,
        userInfo: [
            NSLocalizedDescriptionKey:
                "Usage: swift Scripts/GenerateSnapshotHost.swift [--repository-snapshots|--unit-tests]"
        ]
    )
}
try SnapshotHost(
    packageDirectory: URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent(),
    testName: testName
).generate()
