import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.plain)

        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.borderless)

        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.bordered)

        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.borderedProminent)
    }
}
