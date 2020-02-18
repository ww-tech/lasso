//
//===----------------------------------------------------------------------===//
//
//  SimpleCounter.swift
//
//  Created by Steven Grosmark on 6/16/19.
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
import WWLayout

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
        let controller = SimpleCounterViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
}

class SimpleCounterStore: LassoStore<SimpleCounter> {
    
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

class SimpleCounterViewController: UIViewController, LassoView {
    
    let store: SimpleCounter.ViewStore
    
    init(store: SimpleCounter.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 64, weight: .bold)
        label.textAlignment = .center
        label.backgroundColor = UIColor.yellow.withAlphaComponent(0.25)
        label.set(cornerRadius: 11)
        
        let incButton = UIButton(standardButtonWithTitle: "+1")
        let decButton = UIButton(standardButtonWithTitle: "-1")
        
        view.addSubviews(label, incButton, decButton)
        
        label.layout
            .center(in: .safeArea)
            .size(200, 200)
        
        incButton.layout
            .below(label, offset: 20)
            .right(to: label)
            .width(90)
        decButton.layout
            .below(label, offset: 20)
            .left(to: label)
            .width(90)
        
        store.observeState(\.count) { [weak label] count in
            label?.text = "\(count)"
        }
        
        incButton.bind(to: store, action: .didTapIncrement)
        decButton.bind(to: store, action: .didTapDecrement)
    }
}
