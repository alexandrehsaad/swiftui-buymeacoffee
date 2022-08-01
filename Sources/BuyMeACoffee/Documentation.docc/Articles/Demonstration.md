# Demonstration

A demonstration on how to create and modify the button.

## Overview

No overview available.

## Applying view modifiers
	
1. Apply the standard interaction behavior and appearance.

    ```swift
    BuyMeACoffeeButton(username: "myusername")
        .buttonStyle(BuyMeACoffeeButtonStyle())
    ```
	
2. Customize the standard style with a different tint and font.
    
    ```swift
    BuyMeACoffeeButton(username: "myusername")
        .buttonStyle(BuyMeACoffeeButtonStyle(tint: .orange, font: .cookie))
        .cornerRadius(10)
    ```
	
3. Configure the button to display an icon, a label, or both.

    ```swift
    BuyMeACoffeeButton(username: "myusername")
        .buttonStyle(BuyMeACoffeeButtonStyle())
        .clipShape(Circle())
        .labelStyle(.iconOnly)
    ```
	
## Working with an example

- An example of a button that adapts to the color scheme.

    ```swift
    struct ContentView: View {
        @Environment(\.colorScheme)
        var colorScheme

        var backgroundColor: BuyMeACoffeeColor {
            return colorScheme == .dark ? .black : .white
        }

        var strokeColor: Color {
            return colorScheme == .dark ? .white : .black
        }

        var body: some View {
            BuyMeACoffeeButton(username: "myusername")
                .buttonStyle(BuyMeACoffeeButtonStyle(tint: backgroundColor))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(strokeColor, lineWidth: 1)
                )
        }
    }
    ```
