//
//===----------------------------------------------------------------------===//
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
//===----------------------------------------------------------------------===//
//

import Foundation

public protocol AbstractViewStore: StateObservable, ActionDispatchable { }

/// Public-access, type-erased View Store
/// - receives actions
/// - readable, observable state
public class AnyViewStore<ViewState, ViewAction>: AbstractViewStore {
    
    /// Create a ViewStore
    ///
    /// - Parameters:
    ///   - store: the concrete, source store
    ///   - stateMap: pure function; maps store state to view state
    ///   - actionMap: pure function; maps view action to store action
    internal init<Store: AbstractStore>(_ store: Store, stateMap: @escaping (Store.State) -> ViewState, actionMap: @escaping (ViewAction) -> Store.Action) {
        self.binder = ValueBinder<ViewState>(stateMap(store.state))
        
        self._dispatchAction = { viewAction in
            store.dispatchAction(actionMap(viewAction))
        }
        
        store.observeState { [weak self] (_, newState) in
            self?.binder.set(stateMap(newState))
        }
        
    }
    
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
