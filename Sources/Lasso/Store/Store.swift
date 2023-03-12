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
    public typealias SideEffect = Module.SideEffect
    
    private struct StateValue {
        let state: State
        let sideEffects: Set<SideEffect>
        init(_ state: State, _ effects: Set<SideEffect>) {
            self.state = state
            self.sideEffects = effects
        }
    }
    private let binder: ValueBinder<StateValue>
    
    private var outputBridge = OutputBridge<Output>()
    private var pendingUpdates: [Update<StateProxy<State, SideEffect>>] = []
//    private var sideEffects: ValueBinder<Set<SideEffect>>
    
    public required init(with initialState: State) {
        self.binder = ValueBinder(StateValue(initialState, []))
//        self.sideEffects = ValueBinder([])
    }
    
    // state
    public var state: State {
        return binder.value.state
    }
    private var sideEffects: Set<SideEffect> {
        return binder.value.sideEffects
    }
    
    public func observeState(handler: @escaping (State?, State) -> Void) {
        binder.bind(\.state) { oldState, newState in handler(oldState, newState) }
    }
    
    public func observeState(handler: @escaping (State) -> Void) {
        binder.bind(\.state) { _, newState in handler(newState) }
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value?, Value) -> Void) {
        binder.bind((\StateValue.state).appending(path: keyPath), to: handler)
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value) -> Void) {
        observeState(keyPath) { _, newValue in handler(newValue) }
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value?, Value) -> Void) where Value: Equatable {
        binder.bind((\StateValue.state).appending(path: keyPath), to: handler)
    }
    
    public func observeState<Value>(_ keyPath: WritableKeyPath<State, Value>, handler: @escaping (Value) -> Void) where Value: Equatable {
        observeState(keyPath) { _, newValue in handler(newValue) }
    }
    
    public func observeSideEffects(handler: @escaping (Set<SideEffect>) -> Void) {
        binder.bind(\.sideEffects) { _, newValue in handler(newValue) }
    }
    
    public func observeSideEffect(_ sideEffect: SideEffect, handler: @escaping (SideEffect, Bool) -> Void) {
        binder.bind(\.sideEffects) { oldValue, newValue in
            let isInProgress = newValue.contains(sideEffect)
            guard oldValue?.contains(sideEffect) == true || isInProgress else { return }
            handler(sideEffect, isInProgress)
        }
    }
    
    public func waitForSIdeEffects() async {
        guard !sideEffects.isEmpty else { return }
        await withCheckedContinuation { continuation in
            observeSideEffects { effects in
                if effects.isEmpty {
                    continuation.resume()
                }
            }
        }
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
    
    public func update(_ update: @escaping Update<StateProxy<State, SideEffect>> = { _ in return }) {
        pendingUpdates.append(update)
        applyUpdates()
    }
    
    public func batchUpdate(_ update: @escaping Update<StateProxy<State, SideEffect>>) {
        pendingUpdates.append(update)
    }
    
    private func applyUpdates() {
        let newState = pendingUpdates.reduce(into: StateProxy(state, sideEffects)) { state, update in
            update(&state)
        }
        // TODO: Should probably combine state & sideEffects into a single value binder
        binder.set(StateValue(newState.state, newState.sideEffects))
        pendingUpdates = []
    }
    
}

@dynamicMemberLookup
public struct StateProxy<State, SideEffect: Hashable> {
    
    internal var state: State
    internal var sideEffects: Set<SideEffect>
    
    internal init(_ state: State, _ sideEffects: Set<SideEffect>) {
        self.state = state
        self.sideEffects = sideEffects
    }
    
    public subscript<ValueType>(dynamicMember keyPath: KeyPath<State, ValueType>) -> ValueType {
        state[keyPath: keyPath]
    }
    
    public subscript<ValueType>(dynamicMember keyPath: WritableKeyPath<State, ValueType>) -> ValueType {
        get { state[keyPath: keyPath] }
        set { state[keyPath: keyPath] = newValue }
    }
    
    public mutating func startSideEffect(_ sideEffect: SideEffect) {
        // TODO: Assert it hasn't already been started?
        sideEffects.insert(sideEffect)
    }
    
    public mutating func sideEffectFinished(_ sideEffect: SideEffect) {
        // TODO: Assert it has been sterted?
        sideEffects.remove(sideEffect)
    }
}

extension LassoStore where State: Equatable {
    
    public func observeState(handler: @escaping (State?, State) -> Void) {
        binder.bind(\.state, to: handler)
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
