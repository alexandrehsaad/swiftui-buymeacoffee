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

// TODO: not able to register font.
/*
 Unmanaged<CFErrorRef>(_value: Error Domain=com.apple.CoreText.CTFontManagerErrorDomain Code=105 "Font registration was unsuccessful." UserInfo={NSLocalizedDescription=Font registration was unsuccessful., CTFontManagerErrorFontURLs=("file:///Users/alexandresaad/Library/Developer/CoreSimulator/Devices/1BBCAA49-8BA7-429D-AAF0-016AE7360FCB/data/Containers/Bundle/Application/8BB697A9-2FA2-4701-A53E-37D6FFDB5C85/myapp.app/swiftui-buymeacoffee_BuyMeACoffee.bundle/cookie.ttf")})
 */
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
