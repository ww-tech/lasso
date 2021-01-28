//
// ==----------------------------------------------------------------------== //
//
//  Onboarding.swift
//
//  Created by Steven Grosmark on 5/13/19.
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

/// A sample onboarding-type Flow with five screens sequentially pushed onto a navigation stack.
///
/// The five stages are:
///     - welcome ("welcome to the thing")
///     - name ("enter your name")
///     - counter ("pick a number")
///     - notifications ("hey - turn on notifications")
///     - done ("all done")
enum OnboardingFlowModule: NavigationFlowModule {
    
    enum Output: Equatable {
        case didFinish
    }
    
}

// sample sequential navigation flow
class OnboardingFlow: Flow<OnboardingFlowModule> {
    
    private var nameStore: EnterNameScreenModule.Store?
    private var counterStore: CounterScreenModule.Store?
    
    override func createInitialController() -> UIViewController {
        return assembleController(for: Stage.first)
    }
    
    private func assembleController(for stage: Stage) -> UIViewController {
        
        switch initialScreenState(for: stage) {
            
        case .text(let textState):
            return TextScreenModule
                .createScreen(with: textState)
                .observeOutput({ [weak self] output in
                    switch output {
                    case .didTapButton(let index):
                        switch index {
                        case 0: self?.showNextStage(currentStage: stage)
                        case 1: self?.restart()
                        default: return
                        }
                    }
                    
                })
                .controller
            
        case .enterName(let enterNameState):
            return EnterNameScreenModule.createScreen(with: enterNameState)
                .observeOutput({ [weak self] output in
                    switch output {
                    case .didTapRestart: self?.restart()
                    case .didTapNext: self?.showNextStage(currentStage: stage)
                    }
                })
                .captureStore(as: &nameStore)
                .controller
            
        case .counter(let counterState):
            return CounterScreenModule.createScreen(with: counterState)
                .observeOutput({ [weak self] output in
                    switch output {
                    case .didTapNext: self?.showNextStage(currentStage: stage)
                    }
                })
                .captureStore(as: &counterStore)
                .controller
        }
        
    }
    
    private func showNextStage(currentStage: Stage) {
        guard let nextStage = currentStage.next else {
            return dispatchOutput(.didFinish)
        }
        let nextController = assembleController(for: nextStage)
        nextController.place(with: nextPushedInFlow)
    }
    
    private func restart() {
        guard let welcomeController = initialController else { return }
        context?.popToViewController(welcomeController, animated: true)
        nameStore = nil
        counterStore = nil
    }
    
    private enum Stage: Int, CaseIterable {
        case welcome, name, counter, notifications, done
        
        static var first: Stage { return .welcome }
        
        var next: Stage? {
            return Stage(rawValue: rawValue + 1)
        }
        
    }
    
    private enum ScreenState {
        case text(TextScreenModule.State)
        case enterName(EnterNameScreenModule.State)
        case counter(CounterScreenModule.State)
    }
    
    private func initialScreenState(for stage: Stage) -> ScreenState {
        switch stage {
            
        case .welcome:
            let state = TextScreenModule.State(title: "Welcome",
                                               description: "We just need a little info to get you going...",
                                               buttons: ["Next"])
            return .text(state)
            
        case .notifications:
            let state = TextScreenModule.State(title: "Notifications",
                                               description: "Enable Notifications for the smoothest experience...",
                                               buttons: ["Next", "Start Over"])
            return .text(state)
            
        case .name:
            let state = EnterNameScreenModule.State(title: "Enter you name",
                                                    name: name)
            return .enterName(state)
            
        case .counter:
            let state = CounterScreenModule.State(title: "Rollover points",
                                                  counter: counter,
                                                  style: .light)
            return .counter(state)
            
        case .done:
            let description = """
                Ok, \(name), let's get started!

                By completing this onboarding, you earned \(counter) rollover points!
                """
            let state = TextScreenModule.State(title: "All set",
                                               description: description,
                                               buttons: ["Finish"])
            return .text(state)
        }
    }
    
    private var name: String {
        return nameStore?.state.name ?? ""
    }
    
    private var counter: Int {
        return counterStore?.state.counter ?? 0
    }
    
}
