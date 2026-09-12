import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.glass)
            .foregroundStyle(.black, .yellow)

        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.glassProminent)
            .foregroundStyle(.black, .white)
    }
}
