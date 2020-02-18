//
//===----------------------------------------------------------------------===//
//
//  ScreenFactory.swift
//
//  Created by Trevor Beasty on 10/18/19.
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

extension ScreenModule {
    
    public typealias ScreenFactory = Lasso.ScreenFactory<Self>
    
}

public struct ScreenFactory<Module: ScreenModule> {
    
    public typealias Screen = Module.Screen
    
    private let _createScreen: (Module.State?) -> Screen
    
    public init(createScreen: @escaping (Module.State?) -> Screen) {
        self._createScreen = createScreen
    }
    
    public init(configure: ((Module.ConcreteStore) -> Void)? = nil) {
        self._createScreen = { initialState in
            return Module.createScreen(with: initialState, configure: configure)
        }
    }
    
    public func createScreen(with initialState: Module.State? = nil) -> Screen {
        return _createScreen(initialState)
    }
}

public func screenFactory<Module: ScreenModule>(configure: @escaping (Module.ConcreteStore) -> Void) -> Module.ScreenFactory {
    return Module.ScreenFactory(configure: configure)
}
