//
// ==----------------------------------------------------------------------== //
//
//  ViewStore.swift
//
//  Created by Trevor Beasty on 5/2/19.
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

import Foundation
#if canImport(Combine)
import Combine
#endif

public protocol AbstractViewStore: StateObservable, ActionDispatchable { }

/// Public-access, type-erased View Store
/// - receives actions
/// - readable, observable state
public class AnyViewStore<ViewState, ViewAction>: AbstractViewStore {

    /// Create a `ViewStore`
    ///
    /// - Parameters:
    ///   - store: the concrete, source store
    ///   - stateMap: pure function; maps store state to view state
    ///   - actionMap: pure function; maps view action to store action
    internal init<Store: AbstractViewStore>(
        _ store: Store,
        stateMap: @escaping (Store.State) -> ViewState,
        actionMap: @escaping (ViewAction) -> Store.Action
    ) {
        self.binder = ValueBinder<ViewState>(stateMap(store.state))
        
        self._dispatchAction = { viewAction in
            store.dispatchAction(actionMap(viewAction))
        }
        
        store.observeState { [weak self] (_, newState) in
            self?.binder.set(stateMap(newState))
        }
    }
    
    /// Create a `ViewStore` where the `ViewAction` is `NoAction`.
    ///
    /// - Parameters:
    ///   - store: the concrete, source store
    ///   - stateMap: pure function; maps store state to view state
    internal init<Store: AbstractViewStore>(
        _ store: Store,
        stateMap: @escaping (Store.State) -> ViewState
    ) where ViewAction == NoAction {
        self.binder = ValueBinder<ViewState>(stateMap(store.state))
        
        self._dispatchAction = { _ in }
        
        store.observeState { [weak self] (_, newState) in
            self?.binder.set(stateMap(newState))
        }
    }
    
    #if canImport(Combine)
    /// `objectWillChange` publisher, if available and needed.
    private var _objectWillChange: Any?
    #endif
    
    public func dispatchAction(_ viewAction: ViewAction) {
        _dispatchAction(viewAction)
    }
    
    public var state: ViewState {
        return binder.value
    }
    
    public func observeState(handler: @escaping (ViewState?, ViewState) -> Void) {
        binder.bind(to: handler)
    }
    
    public func observeState(handler: @escaping (ViewState) -> Void) {
        observeState { _, newState in handler(newState) }
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<ViewState, Value>, handler: @escaping (Value?, Value) -> Void) {
        binder.bind(keyPath, to: handler)
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<ViewState, Value>, handler: @escaping (Value) -> Void) {
        observeState(keyPath) { _, newValue in handler(newValue) }
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<ViewState, Value>, handler: @escaping (Value?, Value) -> Void) where Value: Equatable {
        binder.bind(keyPath, to: handler)
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<ViewState, Value>, handler: @escaping (Value) -> Void) where Value: Equatable {
        observeState(keyPath) { _, newValue in handler(newValue) }
    }
    
    private let binder: ValueBinder<ViewState>
    private let _dispatchAction: (ViewAction) -> Void
}

extension AnyViewStore where ViewState: Equatable {
    
    public func observeState(handler: @escaping (ViewState?, ViewState) -> Void) {
        binder.bind(to: handler)
    }
    
    public func observeState(handler: @escaping (ViewState) -> Void) {
        observeState { _, newState in handler(newState) }
    }
    
}

extension AbstractViewStore {
    
    public typealias ActionMap<A> = (A) -> Action
    public typealias StateMap<S> = (State) -> S
    
    /// Create a ViewStore with a ViewState that can be initialized from the Store's State,
    /// using a ViewModule to define the relevant ViewState & ViewAction types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewState
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    /// - Returns: a new ViewStore
    public func asViewStore<Module: ViewModule>(
        for viewModuleType: Module.Type,
        stateMap: @escaping StateMap<Module.ViewState>
    ) -> AnyViewStore<Module.ViewState, Module.ViewAction> where Module.ViewAction == Action {
        asViewStore(stateMap: stateMap, actionMap: { $0 })
    }
    
    /// Create a `ViewStore` with a `ViewState` that can be initialized from the Store's State,
    /// using a `ViewModule` whose `ViewAction` is `NoAction` to define the relevant `ViewState` type.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewState
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    /// - Returns: a new ViewStore
    public func asViewStore<Module: ViewModule>(
        for viewModuleType: Module.Type,
        stateMap: @escaping StateMap<Module.ViewState>
    ) -> AnyViewStore<Module.ViewState, NoAction> where Module.ViewAction == NoAction {
        asViewStore(stateMap: stateMap)
    }
    
    /// Create a `ViewStore` using a subset of actions, with the Store's `State` type,
    /// using a `ViewModule` to define the relevant `ViewState` & `ViewAction` types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewAction
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<Module: ViewModule>(
        for viewModuleType: Module.Type,
        actionMap: @escaping ActionMap<Module.ViewAction>
    ) -> AnyViewStore<Module.ViewState, Module.ViewAction> where Module.ViewState == State {
        asViewStore(stateMap: { $0 }, actionMap: actionMap)
    }
    
    /// Create a `ViewStore` using a subset of actions,
    /// with a `ViewState` that can be initialized from the Store's `State`,
    /// using a `ViewModule` to define the relevant `ViewState` & `ViewAction` types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewState and ViewAction
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<Module: ViewModule>(
        for viewModuleType: Module.Type,
        stateMap: @escaping StateMap<Module.ViewState>,
        actionMap: @escaping ActionMap<Module.ViewAction>
    ) -> AnyViewStore<Module.ViewState, Module.ViewAction> {
        asViewStore(stateMap: stateMap, actionMap: actionMap)
    }
    
    /// Create a `ViewStore` using the Store's `State` and `Action` types,
    /// that provides access to just the `dispatchAction` and `observeState` methods.
    ///
    /// - Returns: a new ViewStore
    public func asViewStore() -> AnyViewStore<State, Action> {
        asViewStore(stateMap: { $0 }, actionMap: { $0 })
    }
    
    /// Create a `ViewStore` with a `ViewState` that can be initialized from the Store's `State`.
    ///
    /// - Parameter stateMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<ViewState>(
        stateMap: @escaping StateMap<ViewState>
    ) -> AnyViewStore<ViewState, Action> {
        asViewStore(stateMap: stateMap, actionMap: { $0 })
    }
    
    /// Create a `ViewStore` using a subset of actions, with the Store's `State` type.
    ///
    /// - Parameter actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<ViewAction>(
        actionMap: @escaping ActionMap<ViewAction>
    ) -> AnyViewStore<State, ViewAction> {
        asViewStore(stateMap: { $0 }, actionMap: actionMap)
    }
    
    /// Create a `ViewStore` using a subset of actions,
    /// with a `ViewState` that can be initialized from the Store's `State`.
    ///
    /// - Parameters:
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    /// - Returns: a new ViewStore
    public func asViewStore<ViewState, ViewAction>(
        stateMap: @escaping StateMap<ViewState>,
        actionMap: @escaping ActionMap<ViewAction>
    ) -> AnyViewStore<ViewState, ViewAction> {
        AnyViewStore<ViewState, ViewAction>(self, stateMap: stateMap, actionMap: actionMap)
    }
    
    /// Create a `ViewStore` with a `ViewState` that can be initialized from the Store's `State`,
    /// and a `ViewAction` of `NoAction`.
    ///
    /// - Parameter stateMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<ViewState>(
        stateMap: @escaping StateMap<ViewState>
    ) -> AnyViewStore<ViewState, NoAction> {
        AnyViewStore<ViewState, NoAction>(self, stateMap: stateMap)
    }
    
}

#if canImport(Combine)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AnyViewStore: ObservableObject {
    
    public typealias StateChangePublisher = PassthroughSubject<ViewState, Never>
    
    public var objectWillChange: StateChangePublisher {
        if let willChange = _objectWillChange as? StateChangePublisher {
            return willChange
        }
        
        let willChange = StateChangePublisher()
        observeState { [weak self] state in
            (self?._objectWillChange as? StateChangePublisher)?.send(state)
        }
        _objectWillChange = willChange
        return willChange
    }
    
}
#endif
