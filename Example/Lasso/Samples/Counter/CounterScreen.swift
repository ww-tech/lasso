//
// ==----------------------------------------------------------------------== //
//
//  CounterModule.swift
//
//  Created by Steven Grosmark on 5/9/19.
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
import Lasso

enum CounterScreenModule: ScreenModule {
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: CounterStore) -> Screen {
        let controller = CounterViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
    enum Action: Equatable {
        case didTapIncrement
        case didTapDecrement
        case didTapNext
    }
    
    enum Output: Equatable {
        case didTapNext
    }
    
    struct State: Equatable {
        let style: Style
        let title: String
        var counter: Int
        
        enum Style { case light, dark, purple }
        
        init(title: String = "", counter: Int = 0, style: Style = .light) {
            self.title = title
            self.counter = max(counter, 0)
            self.style = style
        }
    }
}

class CounterStore: LassoStore<CounterScreenModule> {
    
    override func handleAction(_ action: Action) {
        switch action {
            
        case .didTapIncrement:
            update { state in
                state.counter += 1
            }
            
        case .didTapDecrement:
            update { state in
                state.counter = max(state.counter - 1, 0)
            }
        
        case .didTapNext:
            dispatchOutput(.didTapNext)
        }
    }
}
