// BuyMeACoffeeFont.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

///
public struct BuyMeACoffeeFont {
	///
	internal let font: Font
	
	///
	///
	/// - parameter font:
	private init(_ font: Font) {
		self.font = font
		
		try? Self.registerFont("Cookie")
	}
	
	/// The default font.
	public static let `default`: Self = .init(.system(.title3, design: .default))
	
	/// The cookie font.
	public static let cookie: Self = .init(.custom("Cookie", size: 26, relativeTo: .title3))
	
	/// Registers the specified font.
	///
	/// - parameter fileName:
	/// - parameter fileExtension:
	/// - throws: File does not exist error.
	/// - throws:
	fileprivate static func registerFont(
		_ fileName: String,
		fileExtension: String = ".otf"
	) throws {
		let bundle: Bundle = .module
		
		guard let fileURL: URL = bundle.url(forResource: fileName, withExtension: fileExtension) else {
			throw URLError(.fileDoesNotExist)
		}
		
		var error: Unmanaged<CFError>?
		CTFontManagerRegisterFontsForURL(fileURL as CFURL, .process, &error)
		
		if let error: Unmanaged<CFError> = error {
			throw error.takeUnretainedValue()
		}
	}
}
