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
    
    private var outputBridge = OutputBridge<Output>()
    private var pendingUpdates: [Update<State>] = []
    private let syncQueue = DispatchQueue(label: "lasso-store-sync-queue", target: .global())

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
        executeOnMainThread { [weak self] in
            self?.handleAction(action)
        }
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
        syncQueue.sync {
            pendingUpdates.append(update)
            applyUpdates()
        }
    }
    
    public func batchUpdate(_ update: @escaping Update<State>) {
        syncQueue.sync {
            pendingUpdates.append(update)
        }
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
