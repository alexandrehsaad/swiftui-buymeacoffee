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
	}
	
	/// The default font.
	public static let `default`: Self = .init(.system(.title3, design: .default))
	
	/// The cookie font.
	public static let cookie: Self = .init(.custom("cookie", size: 20, relativeTo: .title3))
}

// TODO: not able to register font from module.
extension Font {
	static func registerFont(
		bundle: Bundle,
		name: String,
		fileExtension: String = "ttf"
	) {
		guard let fontURL: URL = bundle.url(forResource: name, withExtension: fileExtension) else {
				print("Font \(name).\(fileExtension) was not found.")
				return
			}

			var error: Unmanaged<CFError>?
			CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
			print(error ?? "Successfully registered font: \(name)")
	}
}
