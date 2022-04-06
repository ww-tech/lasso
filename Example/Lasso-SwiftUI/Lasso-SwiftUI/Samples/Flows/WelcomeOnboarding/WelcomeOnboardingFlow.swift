//
// ==----------------------------------------------------------------------== //
//
//  WelcomeOnboardingFlow.swift
//
//  Created by Steven Grosmark on 03/25/2021
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
import Lasso

enum WelcomeOnboarding: NavigationFlowModule {
    enum Output: Equatable {
        case didFinish
    }
}

class WelcomeOnboardingFlow: Flow<WelcomeOnboarding> {
    
    override func createInitialController() -> UIViewController {
        assembleFirstScreen()
            .controller
    }
    
    private func assembleFirstScreen() -> WelcomeMessage.Screen {
        WelcomeMessage
            .createScreen(with: WelcomeMessage.State(text: "Welcome!"))
            .observeOutput { [weak self] output in
                if output == .didTapNext {
                    self?.assembleFinalScreen().place(with: self?.nextPushedInFlow)
                }
            }
    }
    
    private func assembleFinalScreen() -> WelcomeMessage.Screen {
        WelcomeMessage
            .createScreen(with: WelcomeMessage.State(text: "Have fun!"))
            .observeOutput { [weak self] output in
                if output == .didTapNext {
                    self?.dispatchOutput(.didFinish)
                }
            }
    }
    
}
