//
//===----------------------------------------------------------------------===//
//
//  PassthroughStore.swift
//
//  Created by Trevor Beasty on 11/20/19.
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

public protocol PassthroughScreenModule: ScreenModule where Action == Output {
    static func createScreen(with store: PassthroughStore<Self>) -> Screen
}

public final class PassthroughStore<Module: PassthroughScreenModule>: LassoStore<Module> {
    
    override public func handleAction(_ action: Action) {
        dispatchOutput(action)
    }
    
}
