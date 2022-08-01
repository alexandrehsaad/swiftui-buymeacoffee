// BuyMeACoffeeButton+View.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

extension BuyMeACoffeeButton: View {
	public var body: some View {
		return Link(destination: self.url) {
			Label {
				self.text
			} icon: {
				Image("buymeacoffee", bundle: .module)
					.imageScale(.large)
			}
			.padding(.vertical, 5)
			.padding(.horizontal, 10)
		}
	}
}






























public struct FullWidthButtonStyle: ButtonStyle {
	public init() {}
	
	public func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.font(.headline.bold())
			.padding(.vertical, 16)
			.frame(maxWidth: .infinity)
			.overlay(configuration.isPressed ? Color.white.opacity(0.2) : .clear)
			.foregroundColor(.white)
			.background(Color.accentColor)
			.cornerRadius(12)
	}
}

public struct CapsuleButtonStyle: ButtonStyle {
	internal let tint: Color?
	
	public init(tint: Color? = nil) {
		self.tint = tint
	}
	
	internal let defaultBackgroundColor: Color = .init(red: 34 / 255, green: 34 / 255, blue: 35 / 255, opacity: 1)
	
	public func makeBody(configuration: Self.Configuration) -> some View {
		return configuration.label
			.font(.body)
			.foregroundColor(self.tint ?? .primary)
			.padding()
			.padding(.horizontal)
			.padding(.horizontal)
			.background(self.tint?.opacity(0.18) ?? self.defaultBackgroundColor)
			.clipShape(Capsule(style: .circular))
			.opacity(configuration.isPressed ? 0.75 : 1)
			.scaleEffect(configuration.isPressed ? 0.97 : 1, anchor: .center)
	}
}
