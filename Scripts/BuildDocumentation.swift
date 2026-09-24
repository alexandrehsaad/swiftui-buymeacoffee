// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import Foundation

guard CommandLine.arguments.count == 1 else {
    print("Usage: BuildDocumentation.swift")
    exit(EXIT_FAILURE)
}

/// The HTML that redirects the site root to DocC's documentation landing page.
fileprivate let redirectHTML: String = "<meta http-equiv=\"refresh\" content=\"0; url=documentation/buymeacoffee/\">\n"

/// The output path of the documentation site's landing page.
fileprivate let landingPagePath: String = ".build/github-pages/index.html"

FileManager.default.changeCurrentDirectoryPath(
    URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().path
)

do {
    let process: Process = .init()
    process.executableURL = .init(fileURLWithPath: "/usr/bin/xcrun")

    // Keep the generated site rooted at .build/github-pages/ for the workflow's Pages artifact upload.
    process.arguments = [
        "xcodebuild", "docbuild", "-scheme", "BuyMeACoffee",
        "-destination", "generic/platform=iOS Simulator",
        "-derivedDataPath", ".build/documentation",
        "CODE_SIGNING_ALLOWED=NO",
        "DOCC_HOSTING_BASE_PATH=swiftui-buymeacoffee",
        "DOCC_TRANSFORM_FOR_STATIC_HOSTING=YES",
        "DOCC_ARCHIVE_PATH=\(URL(fileURLWithPath: ".build/github-pages").path)"
    ]

    try process.run()
    process.waitUntilExit()

    // Do not create or replace the landing page when documentation generation fails.
    guard process.terminationReason == .exit && process.terminationStatus == EXIT_SUCCESS else {
        exit(process.terminationReason == .exit ? process.terminationStatus : EXIT_FAILURE)
    }

    // Redirect the site root to DocC's documentation landing page after a successful build.
    try redirectHTML.write(
        toFile: landingPagePath,
        atomically: true,
        encoding: .utf8
    )
} catch let error {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(EXIT_FAILURE)
}
