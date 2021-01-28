//
// ==----------------------------------------------------------------------== //
//
//  SwiftUI+Lasso.swift
//
//  Created by Steven Grosmark on 1/28/21
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
import Combine

@available(iOS 13.0, *)
extension ScreenModule {
    
    public typealias BindableViewStore = AnyBindableViewStore<State, Action>
}

@available(iOS 13.0, *)
extension AnyScreen {
    
    public init<S: AbstractStore, Content>(_ store: S, _ view: Content)
    where Content: View, S.State == State, S.Action == Action, S.Output == Output {
        self.store = store.asAnyStore()
        self.controller = UIHostingController(rootView: view)
    }
}

@available(iOS 13.0, *)
extension AbstractStore {
    
    /// Create a BindableViewStore with a ViewState that can be initialized from the Store's State,
    /// using a ViewModule to define the relevalnt ViewState & ViewAction types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewState
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    /// - Returns: a new ViewStore
    public func asBindableViewStore<Module: ViewModule>(
        for viewModuleType: Module.Type,
        stateMap: @escaping StateMap<Module.ViewState>
    ) -> AnyBindableViewStore<Module.ViewState, Module.ViewAction>
    where Module.ViewAction == Action {
        return asBindableViewStore(stateMap: stateMap, actionMap: { $0 })
    }
    
    /// Create a BindableViewStore using a subset of actions, with the Store's State type,
    /// using a ViewModule to define the relevalnt ViewState & ViewAction types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewAction
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asBindableViewStore<Module: ViewModule>(
        for viewModuleType: Module.Type,
        actionMap: @escaping ActionMap<Module.ViewAction>
    ) -> AnyBindableViewStore<Module.ViewState, Module.ViewAction>
    where Module.ViewState == State {
        return asBindableViewStore(stateMap: { $0 }, actionMap: actionMap)
    }
    
    /// Create a BindableViewStore using a subset of actions, with a ViewState that can be initialized from the Store's State,
    /// using a ViewModule to define the relevalnt ViewState & ViewAction types.
    ///
    /// - Parameters:
    ///   - viewModuleType: the ViewModule that defines the target ViewState and ViewAction
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asBindableViewStore<Module: ViewModule>(
        for viewModuleType: Module.Type,
        stateMap: @escaping StateMap<Module.ViewState>,
        actionMap: @escaping ActionMap<Module.ViewAction>
    ) -> AnyBindableViewStore<Module.ViewState, Module.ViewAction> {
        return asBindableViewStore(stateMap: stateMap, actionMap: actionMap)
    }
    
    /// Create a BindableViewStore using the Store's State and Action types,
    /// that provides access to just the dispatchAction and observeState methods.
    ///
    /// - Returns: a new ViewStore
    public func asBindableViewStore() -> AnyBindableViewStore<State, Action> {
        return asBindableViewStore(stateMap: { $0 }, actionMap: { $0 })
    }
    
    /// Create a BindableViewStore with a ViewState that can be initialized from the Store's State
    ///
    /// - Parameter stateMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asBindableViewStore<ViewState>(
        stateMap: @escaping StateMap<ViewState>
    ) -> AnyBindableViewStore<ViewState, Action> {
        return asBindableViewStore(stateMap: stateMap, actionMap: { $0 })
    }
    
    /// Create a BindableViewStore using a subset of actions, with the Store's State type.
    ///
    /// - Parameter actionMap: a closure that maps the View's actions to the Store's actions
    /// - Returns: a new ViewStore
    public func asBindableViewStore<ViewAction>(
        actionMap: @escaping ActionMap<ViewAction>
    ) -> AnyBindableViewStore<State, ViewAction> {
        return asBindableViewStore(stateMap: { $0 }, actionMap: actionMap)
    }
    
    /// Create a BindableViewStore using a subset of actions, with a ViewState that can be initialized from the Store's State
    ///
    /// - Parameters:
    ///   - actionMap: a closure that maps the View's actions to the Store's actions
    ///   - stateMap: a closure that converts the Store's State to the ViewState
    /// - Returns: a new ViewStore
    public func asBindableViewStore<ViewState, ViewAction>(
        stateMap: @escaping StateMap<ViewState>,
        actionMap: @escaping ActionMap<ViewAction>
    ) -> AnyBindableViewStore<ViewState, ViewAction> {
        return AnyBindableViewStore<ViewState, ViewAction>(self, stateMap: stateMap, actionMap: actionMap)
    }
    
}

@available(iOS 13.0, *)
@dynamicMemberLookup
public class AnyBindableViewStore<ViewState, ViewAction>: AnyViewStore<ViewState, ViewAction>, ObservableObject {
    
    /// Create a BindableViewStore
    ///
    /// - Parameters:
    ///   - store: the concrete, source store
    ///   - stateMap: pure function; maps store state to view state
    ///   - actionMap: pure function; maps view action to store action
    internal override init<Store: AbstractViewStore>(
        _ store: Store,
        stateMap: @escaping (Store.State) -> ViewState,
        actionMap: @escaping (ViewAction) -> Store.Action
    ) {
        
        super.init(store, stateMap: stateMap, actionMap: actionMap)
        
        observeState { [weak self] state in
            guard let self = self else { return }
            self.objectWillChange.send(state)
        }
        
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<ViewState, U>) -> Binding<U> {
        return Binding(get: { self.state[keyPath: keyPath] },
                       set: { _ = $0 })
    }
    
    public func binding<T>(_ keyPath: WritableKeyPath<ViewState, T>, actionMap: @escaping(T) -> ViewAction) -> Binding<T> {
        return Binding(get: { self.state[keyPath: keyPath] },
                       set: { value in self.dispatchAction(actionMap(value)) })
    }
    
    public func binding<SourceValue, BoundValue>(_ keyPath: WritableKeyPath<ViewState, SourceValue>,
                                                 valueMap: @escaping(SourceValue) -> BoundValue,
                                                 actionMap: @escaping(BoundValue) -> ViewAction) -> Binding<BoundValue> {
        return Binding(get: { valueMap(self.state[keyPath: keyPath]) },
                       set: { value in self.dispatchAction(actionMap(value)) })
    }
    
    public let objectWillChange = PassthroughSubject<ViewState, Never>()
}

@available(iOS 13.0, *)
extension Button {
    
    public init<Target: ActionDispatchable>(_ target: Target, action: Target.Action, label: () -> Label) {
        self.init(action: {
            target.dispatchAction(action)
        }, label: label)
    }
    
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension TextField where Label == Text {
    
    public init<S, State, Action>(
        _ title: S,
        boundTo store: AnyBindableViewStore<State, Action>,
        text: WritableKeyPath<State, String>,
        action: @escaping (String) -> Action,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = {}
    ) where S : StringProtocol {
        self.init(title,
                  text: store.binding(text, actionMap: action),
                  onEditingChanged: onEditingChanged,
                  onCommit: onCommit)
    }
}

#endif
