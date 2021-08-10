//
// ==----------------------------------------------------------------------== //
//
//  SwiftUI+Lasso.swift
//
//  Created by Steven Grosmark on 03/20/21
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
extension AnyScreen {
    
    public init<S: AbstractStore, Content>(_ store: S, _ view: Content)
    where Content: View, S.State == State, S.Action == Action, S.Output == Output {
        self.store = store.asAnyStore()
        self.controller = UIHostingController(rootView: view)
        self.controller.holdReference(to: self.store)
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    public func onAppear<Target: ActionDispatchable>(_ target: Target, action: Target.Action) -> some View {
        return onAppear { target.dispatchAction(action) }
    }
    
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    public func onDisappear<Target: ActionDispatchable>(_ target: Target, action: Target.Action) -> some View {
        return onDisappear { target.dispatchAction(action) }
    }
    
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    public func onTapGesture<Target: ActionDispatchable>(_ target: Target, action: Target.Action) -> some View {
        return onTapGesture { target.dispatchAction(action) }
    }
    
    public func onTapGesture<Target: ActionDispatchable>(count: Int, _ target: Target, action: Target.Action) -> some View {
        return onTapGesture(count: count) { target.dispatchAction(action) }
    }

}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    public func onLongPressGesture<Target: ActionDispatchable>(_ target: Target, action: Target.Action) -> some View {
        return onLongPressGesture { target.dispatchAction(action) }
    }

    public func onLongPressGesture<Target: ActionDispatchable>(
        minimumDuration: Double,
        maximumDistance: CGFloat,
        pressing: ((Bool) -> Void)?,
        target: Target,
        action: Target.Action
    ) -> some View {
        return onLongPressGesture(
            minimumDuration: minimumDuration,
            maximumDistance: maximumDistance,
            pressing: pressing
        ) {
            target.dispatchAction(action)
        }
    }

}

#endif
