//
//===----------------------------------------------------------------------===//
//
//  ScreenModule+Testing.swift
//
//  Created by Trevor Beasty on 10/17/19.
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

import UIKit
import Lasso

extension ScreenModule {
    
    public static func mockScreenFactory(mockScreen: MockScreen<Self>) -> ScreenFactory {
        return ScreenFactory { initialState in
            let mockStore = MockLassoStore<Self>(with: initialState ?? defaultInitialState)
            let mockController = UIViewController()
            mockScreen.mockStore = mockStore
            mockScreen.mockController = mockController
            return AnyScreen<Self>(mockStore, mockController)
        }
    }
    
    public static func mockControllerScreenFactory(configure: ((ConcreteStore) -> Void)? = nil) -> ScreenFactory {
        return ScreenFactory { initialState in
            let store = ConcreteStore(with: initialState ?? defaultInitialState)
            configure?(store)
            let mockController = MockController(store: store.asViewStore())
            return AnyScreen<Self>(store, mockController)
        }
    }
    
}

public func mockScreenFactory<Module: ScreenModule>(mockScreen: MockScreen<Module>) -> Module.ScreenFactory {
    return Module.mockScreenFactory(mockScreen: mockScreen)
}

public func mockControllerScreenFactory<Module: ScreenModule>(configure: ((Module.ConcreteStore) -> Void)? = nil) -> Module.ScreenFactory {
    return Module.mockControllerScreenFactory(configure: configure)
}

public class MockScreen<Module: StoreModule> {
    
    public internal(set) var mockStore: MockLassoStore<Module>?
    public internal(set) var mockController: UIViewController?
    
    public init() { }
    
}

public final class MockController<ViewState, ViewAction>: UIViewController, LassoView {
    
    public let store: ViewStore
    
    public init(store: ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
}

extension ScreenModule {
    
    public typealias MockController = LassoTestUtilities.MockController<State, Action>
    
}
