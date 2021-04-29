//
// ==----------------------------------------------------------------------== //
//
//  SimpleCounter.swift
//
//  Created by Steven Grosmark on 03/24/2021.
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

import UIKit
import SwiftUI
import Lasso

enum SimpleCounter: ScreenModule {
    
    enum Action: Equatable {
        case didTapIncrement
        case didTapDecrement
    }
    
    struct State: Equatable {
        var count: Int = 0
    }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: SimpleCounterStore) -> Screen {
        let view = SimpleCounterView(store: store.asViewStore())
        return Screen(store, view)
    }
}
