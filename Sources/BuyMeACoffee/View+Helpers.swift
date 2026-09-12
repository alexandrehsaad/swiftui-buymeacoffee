// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

extension View {
    @ViewBuilder
    internal func backport<Content>(
        @ViewBuilder content: (Self) -> Content
    ) -> some View
    where Content: View {
        content(self)
    }

    /// Applies a transformation when a condition is true.
    ///
    /// - Parameters:
    ///   - condition: Whether to apply the transformation.
    ///   - content: A closure that transforms this view.
    /// - Returns: The transformed view when the condition is true; otherwise, this view unchanged.
    @ViewBuilder
    internal func `if`<Content>(
        _ condition: Bool,
        @ViewBuilder content: (Self) -> Content
    ) -> some View
    where Content: View {
        if condition {
            content(self)
        } else {
            self
        }
    }

    /// Applies a transformation when an optional value is present.
    ///
    /// - Parameters:
    ///   - value: The optional value that controls whether to apply the transformation.
    ///   - content: A closure that transforms this view using the unwrapped value.
    /// - Returns: The transformed view when the value is present; otherwise, this view unchanged.
    @ViewBuilder
    internal func ifLet<Value, Content>(
        _ value: Value?,
        @ViewBuilder content: (Self, Value) -> Content
    ) -> some View
    where Content: View {
        if let value {
            content(self, value)
        } else {
            self
        }
    }
}
