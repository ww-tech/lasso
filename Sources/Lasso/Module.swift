//
// ==----------------------------------------------------------------------== //
//
//  Module.swift
//
//  Created by Steven Grosmark on 5/13/19.
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

/// A `StoreModule` is used to define the set of types involved in creating a store.
///
/// All communication follows a unidirectional data flow:
/// - `Action`s are typically sent from a view controller to the `Store`.
/// - The `Store` updates it's `State`.
/// - `State` changes are received by setting up observations on the `Store`.
///
/// The `Store` may also emit `Output`.
public protocol StoreModule {
    
    /// `Action` defines the actions that can be dispatched to the `Store`.
    associatedtype Action = NoAction
    
    /// `State` defines the set of properties the `Store` manages.
    associatedtype State = EmptyState
    
    /// `Output` defines the set of signals the `Store` can generate.
    associatedtype Output = NoOutput
    
    /// The primary, type-erased, public access `Store` for the module.
    typealias Store = AnyStore<State, Action, Output>
    
    /// The `ViewStore` is a type-erased lens into the `Store`, that hides the `Output`.
    /// The `ViewStore` is typically used as the interface the view controller sees.
    typealias ViewStore = AnyViewStore<State, Action>
    
}

/// A `ScreenModule` is used to define the set of types involved in creating a "screen".
///
/// A `ScreenModule` is essentially a StoreModule with some extra expectations and
/// conveniences in regards to creating `Store` / `UIViewController` combinations - i.e. `Screen`s
///
/// Typically, there is a 1:1 relationship between a `ScreenModule` and a `UIViewController`.
/// This is realized in the `createScreen` function, where a concrete `UIViewController` must
/// be instantiated and 'hooked into' the controlling `Store`.
public protocol ScreenModule: StoreModule {
    
    associatedtype ConcreteStore: Lasso.ConcreteStore where ConcreteStore.State == State, ConcreteStore.Action == Action, ConcreteStore.Output == Output
    
    typealias Screen = AnyScreen<Self>
    
    static var defaultInitialState: State { get }
    
    static func createScreen(with store: ConcreteStore) -> Screen
    
}

extension ScreenModule {
    
    /// Helper to create a `ScreenModule`'s `Screen` with an initial `State` different from the module's `defaultInitialState`,
    /// _and_ an opportunity to configure the `ConcreteStore` after it is created.
    ///
    /// - Parameter initialState: optional initial `State` (default is the module's `defaultInitialState`).
    /// - Parameter configure: optional closure for configuring the `ConcreteStore` once it has been created - e.g., to inject dependencies.
    public static func createScreen(with initialState: State? = nil, configure: ((ConcreteStore) -> Void)? = nil) -> Screen {
        let concreteStore = ConcreteStore(with: initialState ?? defaultInitialState)
        configure?(concreteStore)
        return createScreen(with: concreteStore)
    }
    
}

extension ScreenModule where State == EmptyState {
    
    public static var defaultInitialState: State { return EmptyState() }
    
}

/// A ViewModule is used when creating a set of types a view controller cares about.
///
/// A ViewModule:
/// 1) 'Erases' the Output from an AbstractStore. The resulting abstraction is more appropriate for use by a
///    a view controller, which should NEVER observe Outputs.
/// 2) Provides an opportunity to transform state into a form that can be more directly digested by a controller.
///    It is thus possible to define all state mappings in a context outside of the view layer, maximizing the amount
///    of testable business logic. In this fashion, it is possible to extract all business logic from the view layer.
public protocol ViewModule {
    
    associatedtype ViewAction = NoAction
    associatedtype ViewState = EmptyState
    
    typealias ViewStore = AnyViewStore<ViewState, ViewAction>
}

/// A FlowModule describes the types that can be used in a flow.
/// FlowModules have Output, and can specify what kind of view controller they are placed in.
public protocol FlowModule {
    
    associatedtype Output = NoOutput
    
    associatedtype RequiredContext: UIViewController = UIViewController
    
}

/// A FlowModule where the RequiredContext is bound to a UINavigationController.
public protocol NavigationFlowModule: FlowModule where RequiredContext == UINavigationController { }

/// A FlowModule with no output.
public enum NoOutputFlow: FlowModule {
    public typealias Output = NoOutput
    public typealias RequiredContext = UIViewController
}

/// A FlowModule with no output, requiring placement in a UINavigationController.
public enum NoOutputNavigationFlow: FlowModule {
    public typealias Output = NoOutput
    public typealias RequiredContext = UINavigationController
}
