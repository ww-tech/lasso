//
// ==----------------------------------------------------------------------== //
//
//  SwiftUI+Bindings.swift
//
//  Created by Steven Grosmark on 03/26/2021
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

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AnyViewStore {
    
    public func binding<T>(_ keyPath: WritableKeyPath<ViewState, T>,
                           action: @escaping(T) -> ViewAction) -> Binding<T> {
        return Binding(get: { self.state[keyPath: keyPath] },
                       set: { value in self.dispatchAction(action(value)) })
    }
    
    public func binding<SourceValue, BoundValue>(_ keyPath: WritableKeyPath<ViewState, SourceValue>,
                                                 value: @escaping(SourceValue) -> BoundValue,
                                                 action: @escaping(BoundValue) -> ViewAction) -> Binding<BoundValue> {
        return Binding(get: { value(self.state[keyPath: keyPath]) },
                       set: { value in self.dispatchAction(action(value)) })
    }
    
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Button {
    
    public init<Target: ActionDispatchable>(_ target: Target, action: Target.Action, label: () -> Label) {
        self.init(
            action: { target.dispatchAction(action) },
            label: label
        )
    }
    
    public init<Target: ActionDispatchable>(_ label: String, target: Target, action: Target.Action) where Label == Text {
        self.init(
            action: { target.dispatchAction(action) },
            label: { Text(label) }
        )
    }
    
    public init<Target: ActionDispatchable>(_ target: Target, animatedAction: Target.Action, label: () -> Label) {
        self.init(
            action: {
                withAnimation {
                    target.dispatchAction(animatedAction)
                }
            },
            label: label
        )
    }
    
    public init<Target: ActionDispatchable>(_ label: String, target: Target, animatedAction: Target.Action) where Label == Text {
        self.init(
            action: {
                withAnimation {
                    target.dispatchAction(animatedAction)
                }
            },
            label: { Text(label) }
        )
    }
    
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension TextField where Label == Text {
    
    public init<S, State, Action>(
        _ title: S,
        boundTo store: AnyViewStore<State, Action>,
        text: WritableKeyPath<State, String>,
        action: @escaping (String) -> Action,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = {}
    ) where S : StringProtocol {
        self.init(title,
                  text: store.binding(text, action: action),
                  onEditingChanged: onEditingChanged,
                  onCommit: onCommit)
    }
}

#endif
