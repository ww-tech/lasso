//
// ==----------------------------------------------------------------------== //
//
//  NavigationRow.swift
//
//  Created by Steven Grosmark on 03/24/2021.
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2021 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import SwiftUI
import Lasso

/// A list item with a NavigationLink appearance, for dispatching a Lasso Action to a Store.
struct NavigationRow<Label>: View where Label: View {
    
    private let action: () -> Void
    private let label: () -> Label
    
    /// NavigationLink with a view builder
    ///
    /// ```
    /// NavigationLink(store, action: .didTapItem(idOfItem)) {
    ///   Image(systemName: "heart")
    ///   Text("Item of the Heart")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - target: The `ViewStore` to receive the `Action`.
    ///   - action: The `Action` to dispatch to the `ViewStore` when the item is tapped.
    ///   - label: The row's content.
    public init<Target: ActionDispatchable>(_ target: Target,
                                            action: Target.Action,
                                            @ViewBuilder label: @escaping () -> Label) {
        self.action = { target.dispatchAction(action) }
        self.label = label
    }
    
    /// NavigationLink with test content
    ///
    /// ```
    /// NavigationLink("An Item", target: store, action: .didTapItem(idOfItem))
    /// ```
    ///
    /// - Parameters:
    ///   - label: The row's string label.
    ///   - target: The `ViewStore` to receive the `Action`.
    ///   - action: The `Action` to dispatch to the `ViewStore` when the item is tapped.
    public init<Target: ActionDispatchable>(_ label: String,
                                            target: Target,
                                            action: Target.Action) where Label == Text {
        self.action = { target.dispatchAction(action) }
        self.label = { Text(label) }
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                label()
                Spacer()
                Image(systemName: "chevron.right").opacity(0.5)
            }
        }
        .buttonStyle(RowStyle())
    }
    
}
