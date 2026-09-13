import BuyMeACoffee
import SwiftUI

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme
    let tints: Array<BuyMeACoffeeTint> = [.black, .white, .yellow]

    VStack {
        ForEach(tints, id: \.self) { tint in
            BuyMeACoffeeButton(username: "")
                .buttonStyle(.buyMeACoffee(tint: tint))
                .overlay {
                    if let borderColor = tint.borderColor(colorScheme: colorScheme) {
                        Capsule()
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
                .clipShape(.capsule)
        }
    }
}
