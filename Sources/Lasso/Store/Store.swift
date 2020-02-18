//
//===----------------------------------------------------------------------===//
//
//  Store.swift
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
//===----------------------------------------------------------------------===//
//

import Foundation

public protocol AbstractStore: StateObservable, ActionDispatchable, OutputObservable { }

public protocol ConcreteStore: AbstractStore {
    init(with initialState: State)
}

open class LassoStore<Module: StoreModule>: ConcreteStore {
    public typealias State = Module.State
    public typealias Action = Module.Action
    public typealias Output = Module.Output
    
    private let binder: ValueBinder<State>
    
    private var outputBridge = OutputBridge<Output>()
    private var pendingUpdates: [Update<State>] = []
    
    public required init(with initialState: State) {
        self.binder = ValueBinder(initialState)
    }
    
    // state
    public var state: State {
        return binder.value
    }
    
    public func observeState(handler: @escaping (State?, State) -> Void) {
        binder.bind(to: handler)
    }
    
    public func observeState(handler: @escaping (State) -> Void) {
        observeState { _, newState in handler(newState) }
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value?, Value) -> Void) {
        binder.bind(keyPath, to: handler)
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value) -> Void) {
        observeState(keyPath) { _, newValue in handler(newValue) }
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value?, Value) -> Void) where Value: Equatable {
        binder.bind(keyPath, to: handler)
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value) -> Void) where Value: Equatable {
        observeState(keyPath) { _, newValue in handler(newValue) }
    }
    
    // actions
    public func dispatchAction(_ action: Action) {
        handleAction(action)
    }
    
    open func handleAction(_ action: Action) {
        return lassoAbstractMethod()
    }
    
    // outputs
    public func observeOutput(_ observer: @escaping (Output) -> Void) {
        outputBridge.register(observer)
    }
    
    public func dispatchOutput(_ output: Output) {
        outputBridge.dispatch(output)
    }
    
    // updates
    
    public typealias Update<T> = (inout T) -> Void
    
    public func update(_ update: @escaping Update<State> = { _ in return }) {
        pendingUpdates.append(update)
        applyUpdates()
    }
    
    public func batchUpdate(_ update: @escaping Update<State>) {
        pendingUpdates.append(update)
    }
    
    private func applyUpdates() {
        let newState = pendingUpdates.reduce(into: state) { state, update in
            update(&state)
        }
        binder.set(newState)
        pendingUpdates = []
    }
    
}

extension LassoStore where State: Equatable {
    
    public func observeState(handler: @escaping (State?, State) -> Void) {
        binder.bind(to: handler)
    }
    
    public func observeState(handler: @escaping (State) -> Void) {
        observeState { _, newState in handler(newState) }
    }
    
}

extension LassoStore where Module.State == EmptyState {
    
    public convenience init() {
        self.init(with: EmptyState())
    }
    
}

extension LassoStore where Module: ScreenModule {
    
    public convenience init() {
        self.init(with: Module.defaultInitialState)
    }
    
}

extension AbstractStore {
    
    public typealias ActionMap<A> = (A) -> Action
    public typealias StateMap<S> = (State) -> S
    
    /// Create a ViewStore with a ViewState that can be initialized from the Store's State,
    /// using a ViewModule to define the relevant ViewState & ViewAction types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewState
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    /// - Returns: a new ViewStore
    public func asViewStore<Module: ViewModule>(for viewModuleType: Module.Type,
                                                stateMap: @escaping StateMap<Module.ViewState>) -> AnyViewStore<Module.ViewState, Module.ViewAction>
        where Module.ViewAction == Action {
            return asViewStore(stateMap: stateMap, actionMap: { $0 })
    }
    
    /// Create a ViewStore using a subset of actions, with the Store's State type,
    /// using a ViewModule to define the relevant ViewState & ViewAction types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewAction
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<Module: ViewModule>(for viewModuleType: Module.Type,
                                                actionMap: @escaping ActionMap<Module.ViewAction>) -> AnyViewStore<Module.ViewState, Module.ViewAction>
        where Module.ViewState == State {
            return asViewStore(stateMap: { $0 }, actionMap: actionMap)
    }
    
    /// Create a ViewStore using a subset of actions, with a ViewState that can be initialized from the Store's State,
    /// using a ViewModule to define the relevant ViewState & ViewAction types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewState and ViewAction
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<Module: ViewModule>(for viewModuleType: Module.Type,
                                                stateMap: @escaping StateMap<Module.ViewState>,
                                                actionMap: @escaping ActionMap<Module.ViewAction>) -> AnyViewStore<Module.ViewState, Module.ViewAction> {
        return asViewStore(stateMap: stateMap, actionMap: actionMap)
    }
    
    /// Create a ViewStore using the Store's State and Action types,
    /// that provides access to just the dispatchAction and observeState methods.
    ///
    /// - Returns: a new ViewStore
    public func asViewStore() -> AnyViewStore<State, Action> {
        return asViewStore(stateMap: { $0 }, actionMap: { $0 })
    }
    
    /// Create a ViewStore with a ViewState that can be initialized from the Store's State
    ///
    /// - Parameter stateMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<ViewState>(stateMap: @escaping StateMap<ViewState>) -> AnyViewStore<ViewState, Action> {
        return asViewStore(stateMap: stateMap, actionMap: { $0 })
    }
    
    /// Create a ViewStore using a subset of actions, with the Store's State type.
    ///
    /// - Parameter actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asViewStore<ViewAction>(actionMap: @escaping ActionMap<ViewAction>) -> AnyViewStore<State, ViewAction> {
        return asViewStore(stateMap: { $0 }, actionMap: actionMap)
    }
    
    /// Create a ViewStore using a subset of actions, with a ViewState that can be initialized from the Store's State
    ///
    /// - Parameters:
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    /// - Returns: a new ViewStore
    public func asViewStore<ViewState, ViewAction>(stateMap: @escaping StateMap<ViewState>,
                                                   actionMap: @escaping ActionMap<ViewAction>) -> AnyViewStore<ViewState, ViewAction> {
        return AnyViewStore<ViewState, ViewAction>(self, stateMap: stateMap, actionMap: actionMap)
    }
    
}

/// Public-access, type-erased Store
/// - receives actions
/// - readable, observable state
/// - receives outputs, observable outputs
public class AnyStore<State, Action, Output>: AnyViewStore<State, Action>, AbstractStore {
    
    internal init<Store: AbstractStore>(_ store: Store) where Store.State == State, Store.Action == Action, Store.Output == Output {
        self._observeOutput = store.observeOutput
        super.init(store, stateMap: { $0 }, actionMap: { $0 })
    }
    
    public func observeOutput(_ observer: @escaping (Output) -> Void) {
        _observeOutput(observer)
    }
    
    private let _observeOutput: (@escaping (Output) -> Void) -> Void
    
}

extension AbstractStore {
    
    public func asAnyStore() -> AnyStore<State, Action, Output> {
        return AnyStore<State, Action, Output>(self)
    }
    
}
