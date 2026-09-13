// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

/// A title appearance supported by `BuyMeACoffeeButton`.
internal struct BuyMeACoffeeFont {
    /// The content used to render the button title.
    private enum Content: Equatable, Hashable, Sendable {
        /// The official Buy Me a Coffee logo.
        case image

        /// A text title using the specified bundled font, or the system font when the name is `nil`.
        ///
        /// - Parameter fontName: The bundled font's PostScript name, or `nil` to use the system font.
        case text(fontName: String?)
    }

    /// The content used to render the button title.
    private let content: Content

    /// Creates a font value and registers its bundled font resource when needed.
    ///
    /// - Parameter name: The resource name of the bundled font, or `nil` to use the system font.
    private init(name: String? = nil) {
        self.content = .text(fontName: name)

        if let name {
            try? Self.registerFont(fileName: name)
        }
    }

    /// Creates a title appearance with the specified content.
    ///
    /// - Parameter content: The content used to render the button title.
    private init(content: Content) {
        self.content = content
    }

    /// The SwiftUI font represented by this value, or `nil` when the title uses the logo.
    internal var font: Font? {
        switch self.content {
        case .text(fontName: .none):
            return .system(.title3, design: .default)

        case .text(fontName: .some(let name)):
            return .custom(name, size: 28, relativeTo: .title3)

        case .image:
            return nil
        }
    }

    /// The unscaled vertical adjustment that optically centers the title.
    internal var verticalOffset: CGFloat {
        switch self {
        case .logo:
            return 3
        default:
            return 0
        }
    }

    /// The official Buy Me a Coffee logo.
    internal static let logo: Self = .init(content: .image)

    /// The Cookie font used by Buy Me a Coffee on the web.
    @available(*, unavailable)
    internal static let cookie: Self = .init(name: "Cookie")

    /// The default title appearance.
    internal static let `default`: Self = .logo

    /// Registers a bundled font for use by SwiftUI.
    ///
    /// - Parameters:
    ///   - fileName: The resource filename without its extension.
    ///   - fileExtension: The resource filename extension.
    /// - Throws: An error when the resource is missing or registration fails.
    private static func registerFont(
        fileName: String,
        fileExtension: String = ".otf"
    ) throws {
        let bundle: Bundle = .module

        guard let fileURL: URL = bundle.url(forResource: fileName, withExtension: fileExtension) else {
            throw URLError(.fileDoesNotExist)
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(fileURL as CFURL, .process, &error)

        if let error {
            throw error.takeUnretainedValue()
        }
    }
}

// MARK: - CaseIterable

extension BuyMeACoffeeFont: CaseIterable {
    internal static var allCases: Array<Self> {
        return [.logo]
    }
}

// MARK: - Equatable

extension BuyMeACoffeeFont: Equatable {}

// MARK: - Hashable

extension BuyMeACoffeeFont: Hashable {}

// MARK: - Sendable

extension BuyMeACoffeeFont: Sendable {}
