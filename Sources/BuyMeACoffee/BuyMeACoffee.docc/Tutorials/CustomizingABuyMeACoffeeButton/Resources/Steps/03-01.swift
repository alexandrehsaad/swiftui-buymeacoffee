import BuyMeACoffee
import SwiftUI

#Preview {
    let tints: Array<BuyMeACoffeeTint> = [.black, .white, .yellow]

    VStack {
        ForEach(tints, id: \.self) { tint in
            BuyMeACoffeeButton(username: "")
                .buttonStyle(.buyMeACoffee(tint: tint, border: .automatic))
        }
    }
}
