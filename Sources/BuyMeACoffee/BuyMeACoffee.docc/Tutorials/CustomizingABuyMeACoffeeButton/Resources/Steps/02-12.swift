import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        BuyMeACoffeeButton(username: "yourusername")
            .labelStyle(.iconOnly)

        BuyMeACoffeeButton(username: "yourusername")
            .labelStyle(.titleOnly)

        BuyMeACoffeeButton(username: "yourusername")
            .labelStyle(.titleAndIcon)
    }
    .buttonStyle(.buyMeACoffee())
}
