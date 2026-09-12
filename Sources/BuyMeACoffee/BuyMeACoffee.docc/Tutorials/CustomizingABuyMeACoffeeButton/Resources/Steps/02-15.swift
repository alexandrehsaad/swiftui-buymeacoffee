import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        ForEach(DynamicTypeSize.allCases, id: \.self) { size in
            BuyMeACoffeeButton(username: "yourusername")
                .buttonStyle(.buyMeACoffee())
                .dynamicTypeSize(size)
        }
    }
}
