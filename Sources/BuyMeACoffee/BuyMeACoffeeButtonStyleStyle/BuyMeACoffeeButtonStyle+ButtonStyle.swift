// BuyMeACoffeeButtonStyle+ButtonStyle.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

extension BuyMeACoffeeButtonStyle: ButtonStyle {
	public func makeBody(configuration: Self.Configuration) -> some View {
		return Group {
			switch self.color {
			case .black:
				configuration.label
					.foregroundStyle(.white, .yellow)
				
			case .white:
				configuration.label
					.foregroundStyle(.black, .yellow)
			
			case .yellow:
				configuration.label
					.foregroundStyle(.black, .white)
			
			default:
				configuration.label
					.foregroundStyle(.black, .yellow)
			}
		}
		.imageScale(self.font == .cookie ? .medium : .large)
		.symbolRenderingMode(.palette)
		.font(self.font.font)
		.background(self.color)
	}
}
