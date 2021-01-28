//
// ==----------------------------------------------------------------------== //
//
//  Welcome.swift
//
//  Created by Steven Grosmark on 6/19/19.
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
import WWLayout
import Lasso

// MARK: - Welcome onboarding flow

enum WelcomeOnboarding: NavigationFlowModule {
    enum Output: Equatable {
        case didFinish
    }
}

class WelcomeOnboardingFlow: Flow<WelcomeOnboarding> {
    
    override func createInitialController() -> UIViewController {
        return assembleFirstScreen().controller
    }
    
    private func assembleFirstScreen() -> Welcome.Screen {
        return Welcome
            .createScreen(with: Welcome.State(text: "Welcome!"))
            .observeOutput { [weak self] output in
                guard output == .didTapNext, let self = self else { return }
                self.assembleFinalScreen().place(with: self.nextPushedInFlow)
        }
    }
    
    private func assembleFinalScreen() -> Welcome.Screen {
        return Welcome
            .createScreen(with: Welcome.State(text: "Have fun!"))
            .observeOutput { [weak self] output in
                guard output == .didTapNext, let self = self else { return }
                self.dispatchOutput(.didFinish)
        }
    }
    
}

// MARK: - Welcome screen

enum Welcome: ScreenModule {
    
    struct State: Equatable {
        let text: String
        init(text: String = "") {
            self.text = text
        }
    }
    
    enum Action: Equatable {
        case didTapNext
    }
    
    enum Output: Equatable {
        case didTapNext
    }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: WelcomeStore) -> Screen {
        let controller = WelcomeViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
}

class WelcomeStore: LassoStore<Welcome> {
    
    override func handleAction(_ action: Welcome.Action) {
        switch action {
            
        case .didTapNext:
            dispatchOutput(.didTapNext)
        }
    }
}

class WelcomeViewController: UIViewController, LassoView {
    
    let store: Welcome.ViewStore
    
    init(store: Welcome.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        let label = UILabel()
        label.font = UIFont(name: "SnellRoundhand-Bold", size: 64)
        label.textAlignment = .center
        label.text = store.state.text
        
        let button = UIButton(standardButtonWithTitle: "Next")
        
        view.addSubviews(label, button)
        
        label.layout
            .fill(.safeArea, except: .bottom, inset: 30)
        
        button.layout
            .fillWidth(of: .safeArea, maximum: 300)
            .bottom(to: .safeArea, offset: -30)
        
        button.bind(to: store, action: .didTapNext)
    }
}
