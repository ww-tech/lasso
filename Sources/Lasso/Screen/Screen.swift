//
// ==----------------------------------------------------------------------== //
//
//  Screen.swift
//
//  Created by Steven Grosmark on 5/16/19.
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2020 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import UIKit

/// A simple struct to hold the screen / view controller created by a ScreenModule's `createScreen` function.
public struct AnyScreen<Module: StoreModule> {
    public typealias State = Module.State
    public typealias Action = Module.Action
    public typealias Output = Module.Output
    public typealias Store = AnyStore<State, Action, Output>
    
    /// The screen's Store
    public let store: Store
    
    /// The screen's view controller
    public let controller: UIViewController
    
    public init<S: AbstractStore>(_ store: S, _ controller: UIViewController)
        where S.State == State, S.Action == Action, S.Output == Output {
            self.store = store.asAnyStore()
            self.controller = controller
            self.controller.holdReference(to: self.store)
    }
    
}

public protocol LassoView {
    
    associatedtype ViewState
    
    associatedtype ViewAction
    
    typealias ViewStore = AnyViewStore<ViewState, ViewAction>
    
    var store: ViewStore { get }
    
}

extension LassoView {
    
    public var state: ViewState {
        get async { await store.state }
    }
    
    public func dispatchAction(_ viewAction: ViewAction) {
        store.dispatchAction(viewAction)
    }
    
}

extension AnyScreen {
    
    // Provide a convenience for chaining creation -> observation -> placement
    @discardableResult
    @MainActor
    public func place<PlacedContext: UIViewController>(with placer: ScreenPlacer<PlacedContext>?) -> AnyScreen {
        lassoPrecondition(placer != nil, "\(self).place(with:) - placer is nil")
        placer?.place(controller)
        return self
    }
    
    // Provide a convenience for chaining creation -> observation -> placement
    @discardableResult
    public func observeOutput(_ handler: @escaping @Sendable (Output) async -> Void) -> AnyScreen {
        store.observeOutput(handler)
        return self
    }
    
    // Provide a convenience for chaining creation -> observation -> placement
    // This version allows simple mapping from the Screen's Output type to another OtherOutput type
    //  - so callers don't have to create a closure do perform simple mapping.
    @discardableResult
    func observeOutput<OtherOutput>(_ handler: @escaping @Sendable (OtherOutput) async -> Void, mapping: @escaping (Output) -> OtherOutput) -> AnyScreen {
        observeOutput { output in
            await handler(mapping(output))
        }
        return self
    }
    
    @discardableResult
    public func setUpController(_ setUp: (UIViewController) -> Void) -> AnyScreen {
        setUp(controller)
        return self
    }
    
    @discardableResult
    public func captureController(as ref: inout UIViewController?) -> AnyScreen {
        ref = controller
        return self
    }
    
    @discardableResult
    public func captureStore(as ref: inout Store?) -> AnyScreen {
        ref = store
        return self
    }
    
}
