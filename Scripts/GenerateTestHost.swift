// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import Foundation

// MARK: - TestHostGenerationError

/// An error produced while selecting or generating a test host.
fileprivate enum TestHostGenerationError {
    /// The command-line arguments do not select a supported target.
    case invalidArguments

    /// The lockfile does not contain the required SnapshotTesting pin.
    case missingDependency

    /// The project inputs could not be read or its generated files could not be written.
    ///
    /// - Parameter underlyingError: The original file-system, serialization, or process error.
    case generationFailed(underlyingError: any Error)
}

// MARK: - CustomStringConvertible

extension TestHostGenerationError: CustomStringConvertible {
    fileprivate var description: String {
        switch self {
        case .invalidArguments:
            return "Usage: swift Scripts/GenerateTestHost.swift [--repository-snapshots|--unit-tests]"
        case .missingDependency:
            return "Package.resolved must contain swift-snapshot-testing. Resolve package dependencies first."
        case .generationFailed(let underlyingError):
            return "Could not generate the test host: \(underlyingError)"
        }
    }
}

// MARK: - Error

extension TestHostGenerationError: Error {}

// MARK: - Arguments

/// The command-line selection of the hosted test suite.
fileprivate struct Arguments {
    /// The target name shared by the generated project and its test sources.
    fileprivate let testName: String

    /// Selects button snapshot tests, repository snapshot tests, or unit tests.
    ///
    /// - Parameter arguments: Arguments following the script name.
    /// - Throws: `TestHostGenerationError.invalidArguments` for unsupported options.
    fileprivate init(_ arguments: Array<String>) throws(TestHostGenerationError) {
        switch arguments {
        case []:
            self.testName = "BuyMeACoffeeSnapshotTests"
        case ["--repository-snapshots"]:
            self.testName = "RepositorySnapshotTests"
        case ["--unit-tests"]:
            self.testName = "BuyMeACoffeeUnitTests"
        default:
            throw TestHostGenerationError.invalidArguments
        }
    }
}

// MARK: - GeneratedProject

/// Serialized project contents and target identifiers needed to create its scheme.
fileprivate struct GeneratedProject {
    /// Complete XML property list for the generated Xcode project.
    fileprivate let data: Data

    /// Project identifier of the application target.
    fileprivate let applicationID: String

    /// Project identifier of the hosted test target.
    fileprivate let testsID: String

    /// Creates the serialized project and the identifiers used by its shared scheme.
    ///
    /// - Parameters:
    ///   - data: Complete XML property list for the generated Xcode project.
    ///   - applicationID: Project identifier of the host application target.
    ///   - testsID: Project identifier of the hosted test target.
    fileprivate init(
        data: Data,
        applicationID: String,
        testsID: String
    ) {
        self.data = data
        self.applicationID = applicationID
        self.testsID = testsID
    }
}

// MARK: - ResolvedDependency

/// SnapshotTesting's repository and exact commit from the package lockfile.
fileprivate struct ResolvedDependency {
    /// Repository URL recorded by SwiftPM.
    fileprivate let location: String

    /// Resolved commit used by both the package and generated host.
    fileprivate let revision: String

    /// Creates a dependency reference from the package lockfile.
    ///
    /// - Parameters:
    ///   - location: The dependency's repository URL.
    ///   - revision: The exact Git commit to use in the generated project.
    fileprivate init(
        location: String,
        revision: String
    ) {
        self.location = location
        self.revision = revision
    }
}

// MARK: - TestHost

/// Generates a disposable host application, project, and scheme for unit tests and snapshot tests.
fileprivate struct TestHost {
    /// Repository containing the package manifest and original test sources.
    fileprivate let packageDirectory: URL

    /// Name shared by the generated test target and recorder filters.
    fileprivate let testName: String

    /// File manager used to discover sources and write generated files.
    private let manager = FileManager.default

    /// Creates a generator for the selected test target in the package.
    ///
    /// - Parameters:
    ///   - packageDirectory: The repository containing the manifest, lockfile, and original test sources.
    ///   - testName: The test target name, also used to locate its directory beneath `Tests`.
    fileprivate init(
        packageDirectory: URL,
        testName: String
    ) {
        self.packageDirectory = packageDirectory
        self.testName = testName
    }

    /// Disposable directory containing the application source and project.
    private var hostDirectory: URL {
        return packageDirectory.appendingPathComponent(".build/tests/Host")
    }

    /// Xcode project consumed by the recording script and CI.
    private var projectDirectory: URL {
        return hostDirectory.appendingPathComponent("TestHost.xcodeproj")
    }

    /// Creates the host while preserving unchanged files for incremental builds.
    ///
    /// - Throws: `TestHostGenerationError` if inputs are invalid or the project cannot be generated.
    fileprivate func run() throws(TestHostGenerationError) {
        do {
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
                to: projectDirectory.appendingPathComponent("xcshareddata/xcschemes/TestHost.xcscheme")
            )
            print("Generated test host: \(projectDirectory.path)")
        } catch let error as TestHostGenerationError {
            throw error
        } catch let error {
            throw TestHostGenerationError.generationFailed(underlyingError: error)
        }
    }

    /// Finds immediate Swift test files in stable path order without copying their contents.
    ///
    /// - Returns: Absolute source URLs, keeping snapshot paths anchored in the repository.
    /// - Throws: An error if the test directory cannot be read.
    private func testSources() throws -> Array<URL> {
        // Directory containing the original test sources.
        let testDirectory = packageDirectory.appendingPathComponent("Tests/\(self.testName)")

        // Immediate Swift source files, sorted by path to make project generation deterministic.
        let sources = try manager.contentsOfDirectory(at: testDirectory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
            .sorted { $0.path < $1.path }

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
        guard let lock = try JSONSerialization.jsonObject(with: lockData) as? Dictionary<String, Any>,
            let pins = lock["pins"] as? Array<Dictionary<String, Any>>,
            let pin = pins.first(where: { $0["identity"] as? String == "swift-snapshot-testing" }),
            let location = pin["location"] as? String,
            let state = pin["state"] as? Dictionary<String, Any>,
            let revision = state["revision"] as? String
        else {
            throw TestHostGenerationError.missingDependency
        }

        return ResolvedDependency(
            location: location,
            revision: revision
        )
    }

    /// Writes the minimal SwiftUI application that supplies a window for glass rendering.
    ///
    /// - Throws: Directory creation or file-writing errors.
    private func writeApplication() throws {
        // A real application window lets the snapshot tests capture system visual effects.
        try write(
            Data(
                ("import SwiftUI\n"
                    + "@main struct TestHostApp: App { var body: some Scene { WindowGroup { Color.clear } } }\n")
                    .utf8
            ),
            to: hostDirectory.appendingPathComponent("TestHostApp.swift")
        )
    }

    /// Creates the comparison scheme; recording is enabled separately in disposable test-run files.
    ///
    /// - Parameter project: Target identifiers produced by the project builder.
    /// - Returns: UTF-8 XML describing the shared scheme.
    private func comparisonScheme(for project: GeneratedProject) -> Data {
        // Scheme buildable reference identifying the host application target.
        let appRef = reference(project.applicationID, "TestHost", "TestHost.app")

        // Scheme buildable reference identifying the selected test target.
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
        return "<BuildableReference BuildableIdentifier=\"primary\" BlueprintIdentifier=\"\(id)\""
            + " BuildableName=\"\(product)\" BlueprintName=\"\(name)\""
            + " ReferencedContainer=\"container:TestHost.xcodeproj\"/>"
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
fileprivate final class SnapshotProjectBuilder {
    /// Project object table, keyed by the identifiers returned by `object(_:_:)`.
    private var objects: Dictionary<String, Any> = [:]

    /// Counter used to assign stable identifiers when objects are created in the same order.
    private var nextID = 0

    /// Creates an empty project builder with its identifier counter starting at zero.
    ///
    /// Use a fresh builder for each project so object identifiers remain deterministic across generations.
    fileprivate init() {}

    /// Adds a typed object to the project table and returns its generated identifier.
    ///
    /// - Parameters:
    ///   - isa: Xcode project object type, such as `PBXNativeTarget`.
    ///   - values: Fields for the object; the explicit type overrides any supplied `isa` field.
    /// - Returns: A unique, 24-digit hexadecimal project identifier.
    private func object(_ isa: String, _ values: Dictionary<String, Any>) -> String {
        nextID += 1
        let id = String(format: "%024X", nextID)
        objects[id] = values.merging(["isa": isa]) { _, new in new }
        return id
    }

    /// Creates Debug and Release configurations with identical settings for hosted test builds.
    ///
    /// - Parameter settings: Build settings applied to both configurations.
    /// - Returns: The identifier of a configuration list whose default is Debug.
    private func configurations(_ settings: Dictionary<String, Any>) -> String {
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
                "defaultConfigurationIsVisible": "0", "defaultConfigurationName": "Debug"
            ]
        )
    }

    /// Creates a build phase that participates in ordinary builds.
    ///
    /// - Parameters:
    ///   - isa: Build phase type, such as `PBXSourcesBuildPhase`.
    ///   - files: Build-file object identifiers included in the phase; defaults to an empty phase.
    /// - Returns: The new build phase identifier.
    private func phase(_ isa: String, _ files: Array<String> = []) -> String {
        return object(
            isa,
            [
                "buildActionMask": "2147483647",
                "files": files,
                "runOnlyForDeploymentPostprocessing": "0"
            ]
        )
    }

    /// Shared simulator build settings; iOS 26 enables glass styles and testability exposes internal declarations.
    private let common: Dictionary<String, Any> = [
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
        "PRODUCT_NAME": "$(TARGET_NAME)"
    ]

    /// Creates configurations by applying target-specific overrides to the shared settings.
    ///
    /// - Parameter extra: Settings that replace matching shared values or add target-specific values.
    /// - Returns: The target's configuration list identifier.
    private func settings(_ extra: Dictionary<String, Any>) -> String {
        return configurations(common.merging(extra) { _, new in new })
    }

    /// Constructs the Xcode object graph and serializes it for the host writer.
    ///
    /// - Parameters:
    ///   - root: Absolute repository URL used by the local package reference.
    ///   - sources: Original test files in deterministic order.
    ///   - dependency: SnapshotTesting repository and revision from the package lockfile.
    ///   - testName: Name of the hosted test target.
    /// - Returns: Serialized project data and the target identifiers required by its scheme.
    /// - Throws: Property-list serialization errors.
    fileprivate func build(
        root: URL,
        sources: Array<URL>,
        dependency: ResolvedDependency,
        testName: String
    ) throws -> GeneratedProject {
        // Project reference to the generated SwiftUI host application source.
        let appSource = object(
            "PBXFileReference",
            [
                "path": "TestHostApp.swift",
                "sourceTree": "<group>",
                "lastKnownFileType": "sourcecode.swift"
            ]
        )

        // Absolute references to original test files, preserving their snapshot reference locations.
        let testSources = sources.map {
            object(
                "PBXFileReference",
                [
                    "path": $0.path,
                    "sourceTree": "<absolute>",
                    "lastKnownFileType": "sourcecode.swift"
                ]
            )
        }

        // Build-product reference for the host application bundle.
        let appProduct = object(
            "PBXFileReference",
            [
                "path": "TestHost.app",
                "sourceTree": "BUILT_PRODUCTS_DIR",
                "explicitFileType": "wrapper.application"
            ]
        )

        // Build-product reference for the hosted test bundle.
        let testProduct = object(
            "PBXFileReference",
            [
                "path": "\(testName).xctest",
                "sourceTree": "BUILT_PRODUCTS_DIR",
                "explicitFileType": "wrapper.cfbundle"
            ]
        )

        // Project navigator group containing the generated build products.
        let products = object(
            "PBXGroup",
            [
                "name": "Products",
                "sourceTree": "<group>",
                "children": [appProduct, testProduct]
            ]
        )

        // Root navigator group containing application source, test sources, and products.
        let group = object(
            "PBXGroup",
            [
                "sourceTree": "<group>",
                "children": [appSource] + testSources + [products]
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
                    "revision": dependency.revision
                ]
            ]
        )

        // Package product references linked into the hosted test target.
        let dependencies = [
            (package, "BuyMeACoffee"),
            (package, "BuyMeACoffeeSnapshotTesting"),
            (snapshotPackage, "SnapshotTesting")
        ].map {
            object("XCSwiftPackageProductDependency", ["package": $0.0, "productName": $0.1])
        }

        // Native application target providing the window required for glass snapshots.
        let app = object(
            "PBXNativeTarget",
            [
                "name": "TestHost",
                "productName": "TestHost",
                "productType": "com.apple.product-type.application",
                "productReference": appProduct,
                "buildConfigurationList": settings([
                    "PRODUCT_BUNDLE_IDENTIFIER": "org.buymeacoffee.TestHost",
                    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                    "INFOPLIST_KEY_UILaunchScreen_Generation": "YES"
                ]),
                "buildPhases": [
                    phase("PBXSourcesBuildPhase", [object("PBXBuildFile", ["fileRef": appSource])]),
                    phase("PBXFrameworksBuildPhase"),
                    phase("PBXResourcesBuildPhase")
                ],
                "buildRules": [],
                "dependencies": []
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
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/TestHost.app/TestHost", "BUNDLE_LOADER": "$(TEST_HOST)"
                ]),
                "buildPhases": [
                    phase("PBXSourcesBuildPhase", testSources.map { object("PBXBuildFile", ["fileRef": $0]) }),
                    phase(
                        "PBXFrameworksBuildPhase",
                        dependencies.map { object("PBXBuildFile", ["productRef": $0]) }
                    ),
                    phase("PBXResourcesBuildPhase")
                ],
                "buildRules": [],
                "dependencies": [object("PBXTargetDependency", ["target": app])],
                "packageProductDependencies": dependencies
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
                "attributes": ["TargetAttributes": [tests: ["TestTargetID": app]]]
            ]
        )

        // Xcode expects string values for project format versions, even in an XML property list.
        let data = try PropertyListSerialization.data(
            fromPropertyList: [
                "archiveVersion": "1",
                "objectVersion": "56",
                "classes": [:],
                "objects": objects,
                "rootObject": projectID
            ],
            format: .xml,
            options: 0
        )

        return GeneratedProject(
            data: data,
            applicationID: app,
            testsID: tests
        )
    }
}

// MARK: - Generation

do throws(TestHostGenerationError) {
    let arguments: Arguments = try .init(Array(CommandLine.arguments.dropFirst()))
    // Resolve the repository from this script rather than the caller's working directory.
    let packageDirectory: URL = .init(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let host: TestHost = .init(
        packageDirectory: packageDirectory,
        testName: arguments.testName
    )
    try host.run()
} catch let error {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(EXIT_FAILURE)
}
