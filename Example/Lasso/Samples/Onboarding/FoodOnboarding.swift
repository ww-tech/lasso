//
// ==----------------------------------------------------------------------== //
//
//  FoodOnboarding.swift
//
//  Created by Steven Grosmark on 5/20/19.
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

enum FoodOnboarding: NavigationFlowModule {
    
    enum Output: Equatable {
        case didFinish
    }
    
}

/// Displays a series of Food Onboarding screens.
///
/// This flow emits the Output `.didFinish` once all of the onboarding screens have been shown.
/// This flow requires that it is placed in a  navigation controller.
class FoodOnboardingFlow: Flow<FoodOnboarding> {
    
    override func createInitialController() -> UIViewController {
        return assembleScreen(for: Stage.first).controller
    }
    
    /// Create and return the Screen for a specific onboarding Stage
    private func assembleScreen(for stage: Stage) -> TextScreenModule.Screen {
        return TextScreenModule
            .createScreen(with: textState(for: stage))
            .observeOutput { [weak self] output in
                guard let self = self else { return }
                switch output {
                    
                case .didTapButton:
                    guard let nextStage = stage.next else {
                        self.dispatchOutput(.didFinish)
                        return
                    }
                    self.assembleScreen(for: nextStage)
                        .place(with: self.nextPushedInFlow)
                }
            }
    }
    
    /// Retrieve the appropriate State for a specific onboarding Stage
    private func textState(for stage: Stage) -> TextScreenModule.State {
        switch stage {
            
        case .welcome:
            return TextScreenModule.State(title: "Welcome",
                                          description: "We just need a little info to get you going...",
                                          buttons: ["Next"])
            
        case .notifications:
            return TextScreenModule.State(title: "Notifications",
                                          description: "Enable Notifications for the smoothest experience...",
                                          buttons: ["Next"])
            
        case .done:
            return TextScreenModule.State(title: "All set",
                                          description: "Ok, let's get started!",
                                          buttons: ["Finish"])
        }
    }
    
    private enum Stage: Int {
        case welcome = 1, notifications, done
        
        static var first: Stage { return .welcome }
        
        var next: Stage? {
            return Stage(rawValue: rawValue + 1)
        }
        
    }
    
}
