//
//===----------------------------------------------------------------------===//
//
//  StoreTesting+WhenStatement.swift
//
//  Created by Trevor Beasty on 9/30/19.
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
import XCTest
import Lasso

public typealias WhenStatement<Action> = (_ dispatchAction: (Action) -> Void) -> Void

public func actions<Action>(_ actions: Action...) -> WhenStatement<Action> {
    return { dispatchAction in
        actions.forEach(dispatchAction)
    }
}

public func sideEffects<Action>(_ sideEffects: @escaping () -> Void) -> WhenStatement<Action> {
    return { _ in
        sideEffects()
    }
}
