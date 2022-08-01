// BuyMeACoffeeColor.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

///
public struct BuyMeACoffeeColor {
	///
	internal let color: Color
	
	///
	///
	/// - parameter color:
	private init(_ color: Color) {
		self.color = color
	}
	
	/// A black color.
	public static let black: Self = .init(.black)
	
	/// A blue color.
	public static let blue: Self = .init(
		.init(red: 102 / 255, green: 126 / 255, blue: 247 / 255)
	)
	
	/// A green color.
	public static let green: Self = .init(
		.init(red: 143 / 255, green: 212 / 255, blue: 183 / 255)
	)
	
	/// An orange color.
	public static let orange: Self = .init(
		.init(red: 239 / 255, green: 136 / 255, blue: 79 / 255)
	)
	
	/// A purple color.
	public static let purple: Self = .init(
		.init(red: 177 / 255, green: 100 / 255, blue: 247 / 255)
	)
	
	/// A red color.
	public static let red: Self = .init(
		.init(red: 236 / 255, green: 106 / 255, blue: 101 / 255)
	)
	
	/// A yellow color.
	public static let yellow: Self = .init(
		.init(red: 249 / 255, green: 222 / 255, blue: 74 / 255)
	)
	
	/// A white color.
	public static let white: Self = .init(.white)
}
