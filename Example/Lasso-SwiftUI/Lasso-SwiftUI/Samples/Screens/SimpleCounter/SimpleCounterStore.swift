//
// ==----------------------------------------------------------------------== //
//
//  SimpleCounterStore.swift
//
//  Created by Steven Grosmark on 03/25/2021.
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

import Foundation
import Lasso

final class SimpleCounterStore: LassoStore<SimpleCounter> {
    
    override func handleAction(_ action: Action) {
        switch action {
        
        case .didTapIncrement:
            update { state in
                state.count += 1
            }
            
        case .didTapDecrement:
            update { state in
                state.count = max(state.count - 1, 0)
            }
        }
    }
}
