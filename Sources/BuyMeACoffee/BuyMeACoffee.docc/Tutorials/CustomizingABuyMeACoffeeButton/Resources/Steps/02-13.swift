import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        ForEach(ControlSize.allCases, id: \.self) { size in
            BuyMeACoffeeButton(username: "yourusername")
                .buttonStyle(.buyMeACoffee())
                .controlSize(size)
        }
    }
}
