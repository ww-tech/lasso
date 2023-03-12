//
// ==----------------------------------------------------------------------== //
//
//  SideEffectSample.swift
//
//  Created by Steven Grosmark on 10/24/22
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2022 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import SwiftUI
import Combine
import Lasso

enum SideEffectSample: ScreenModule {
    
    enum Action: Equatable {
        case didTapStart
        case didTapStop
    }
    
    enum SideEffect: Hashable {
        case theProcess
    }
    
    struct State {
        var count: Int = 0
    }
    
    static func createScreen(with store: SideEffectSampleStore) -> Screen {
        Screen(store, SideEffectSampleViewController(store: store.asViewStore()))
    }
    
    static var defaultInitialState: State { State() }
}

class SideEffectSampleStore: LassoStore<SideEffectSample> {
    
    override func handleAction(_ action: LassoStore<SideEffectSample>.Action) {
        switch action {
            
        case .didTapStart:
            update { state in
                state.startSideEffect(.theProcess)
            }
            // start some long-running process
            
        case .didTapStop:
            // i.e., the long-running process has finished
            update { state in
                state.sideEffectFinished(.theProcess)
            }
        }
    }
}

class SideEffectSampleViewController: UIViewController, LassoView {
    
    let store: SideEffectSample.ViewStore
    
    init(store: SideEffectSample.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        let titleLabel = UILabel(headline: "The Progress")
        
        let startButton = UIButton(type: .system).set(title: "Start", with: .systemFont(ofSize: 32))
        let stopButton = UIButton(type: .system).set(title: "Stop", with: .systemFont(ofSize: 32))
        
        let indicator = UIActivityIndicatorView(style: .mediumGray)
        
        view.addSubviews(titleLabel, indicator, startButton, stopButton)
        
        titleLabel.layout
            .center(in: .safeArea)
        
        startButton.layout
            .below(titleLabel, offset: 20)
            .trailing(to: titleLabel, edge: .center, offset: -20)
        
        stopButton.layout
            .below(titleLabel, offset: 20)
            .leading(to: titleLabel, edge: .center, offset: 20)
        
        indicator.layout
            .bottom(to: titleLabel, edge: .top, offset: -20)
            .centerX(to: titleLabel)
        
        startButton.bind(to: store, action: .didTapStart)
        stopButton.bind(to: store, action: .didTapStop)
        
        store.observeSideEffect(.theProcess) { _, isInProgress in
            indicator.isAnimating = isInProgress
        }
    }
    
}
