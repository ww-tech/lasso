//
// ==----------------------------------------------------------------------== //
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
// ==----------------------------------------------------------------------== //
//

import Foundation

public protocol AbstractStore: AbstractViewStore, OutputObservable { }

public protocol ConcreteStore: AbstractStore {
    init(with initialState: State)
}

open class LassoStore<Module: StoreModule>: ConcreteStore {
    public typealias State = Module.State
    public typealias Action = Module.Action
    public typealias Output = Module.Output
    
    private let binder: ValueBinder<State>
    private var _state: State
    private var pendingUpdates: [Update<State>] = []
    
    private let outputBridge = OutputBridge<Output>()

    public required init(with initialState: State) {
        self.binder = ValueBinder(initialState)
        self._state = initialState
    }
    
    // state
    public var state: State {
        @MainActor get { _state }
    }
    
    public func observeState(handler: @escaping ValueObservation<State>) {
        Task {
            await binder.bind(to: handler)
        }
    }
    
    public func observeState(
        handler: @escaping @Sendable (State) async -> Void
    ) {
        observeState { _, newState in await handler(newState) }
    }
    
    public func observeState<Value>(
        _ keyPath: WritableKeyPath<State, Value>,
        handler: @escaping ValueObservation<Value>
    ) {
        Task {
            await binder.bind(keyPath, to: handler)
        }
    }
    
    public func observeState<Value>(
        _ keyPath: WritableKeyPath<State, Value>,
        handler: @escaping @Sendable (Value) async -> Void
    ) {
        observeState(keyPath) { _, newValue in await handler(newValue) }
    }
    
    public func observeState<Value>(
        _ keyPath: WritableKeyPath<State, Value>,
        handler: @escaping ValueObservation<Value>
    ) where Value: Equatable {
        Task {
            await binder.bind(keyPath, to: handler)
        }
    }
    
    public func observeState<Value>(
        _ keyPath: WritableKeyPath<State, Value>,
        handler: @escaping @Sendable (Value) async -> Void
    ) where Value: Equatable {
        observeState(keyPath) { _, newValue in await handler(newValue) }
    }
    
    // actions
    public func dispatchAction(_ action: Action) {
        Task {
            await handleAction(action)
        }
    }
    
    @MainActor
    open func handleAction(_ action: Action) {
        return lassoAbstractMethod()
    }
    
//    open func handleAction(_ action: Action) async {
//        await handleActionOnMainThread(action)
//    }
//
//    @MainActor
//    private func handleActionOnMainThread(_ action: Action) {
//        handleAction(action)
//    }
    
    // outputs
    public func observeOutput(_ observer: @escaping OutputObservation) {
        Task {
            await outputBridge.register(observer)
        }
    }
    
    public func dispatchOutput(_ output: Output) {
        Task {
            await outputBridge.dispatch(output)
        }
    }
    
    // updates
    
    public typealias Update<T> = @Sendable (inout T) -> Void
    
    @MainActor
    public func update(_ update: @escaping Update<State> = { _ in return }) {
        updateState(using: update, apply: true)
    }
    
    @MainActor
    public func batchUpdate(_ update: @escaping Update<State>) {
        updateState(using: update, apply: false)
    }
    
    @MainActor
    private func updateState(using update: @escaping Update<State>, apply: Bool) {
        pendingUpdates.append(update)
        guard apply else { return }
        
        let newState = pendingUpdates.reduce(into: state) { state, update in
            update(&state)
        }
        self._state = newState
        Task {
            await binder.set(newState)
        }
    }
    
}

extension LassoStore where State: Equatable {
    
    public func observeState(handler: @escaping ValueObservation<State>) {
        Task {
            await binder.bind(to: handler)
        }
    }
    
    public func observeState(handler: @escaping @Sendable (State) async -> Void) {
        observeState { _, newState in await handler(newState) }
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

/// Public-access, type-erased Store
/// - receives actions
/// - readable, observable state
/// - receives outputs, observable outputs
public class AnyStore<State, Action, Output>: AnyViewStore<State, Action>, AbstractStore {
    
    internal init<Store: AbstractStore>(_ store: Store) where Store.State == State, Store.Action == Action, Store.Output == Output {
        self._observeOutput = store.observeOutput
        super.init(store, stateMap: { $0 }, actionMap: { $0 })
    }
    
    public func observeOutput(_ observer: @escaping @Sendable (Output) async -> Void) {
        _observeOutput(observer)
    }
    
    private let _observeOutput: (@escaping @Sendable (Output) async -> Void) -> Void
    
}

extension AbstractStore {
    
    public func asAnyStore() -> AnyStore<State, Action, Output> {
        return AnyStore<State, Action, Output>(self)
    }
    
}
