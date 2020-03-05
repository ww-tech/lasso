//
//===----------------------------------------------------------------------===//
//
//  SampleCatalogFlow.swift
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
//===----------------------------------------------------------------------===//
//

import UIKit
import Lasso

class SampleCatalogFlow: Flow<NoOutputNavigationFlow> {
    
    override func createInitialController() -> UIViewController {
        return SampleCatalog.createScreen()
            .observeOutput { [weak self] in self?.handleOutput($0) }
            .controller
    }
    
    private func handleOutput(_ output: SampleCatalog.Output) {
        guard case let .didSelectItem(item) = output else { return }
        switch item {
        
        case .presentationSimpleCounter:
            SimpleCounter.createScreen().place(with: nextPushedInFlow)
        
        case .presentationOnboarding:
            WelcomeOnboardingFlow()
                .observeOutput { [weak self] _ in self?.unwind() }
                .start(with: nextPresentedInFlow?.withDismissibleNavigationEmbedding())
            
        case .counter:
            showCounterScreen()
            
        case .search:
            showSearchScreen()
            
        case .randomItems:
            RandomItemsFlow().start(with: nextPushedInFlow)
            
        case .tabs:
            TabsFlow().start(with: nextPresentedInFlow?.withDismissibleNavigationEmbedding())
            
        case .splitView:
            showSplitViewFlow()
        
        case .bindings:
            UIKitBindingsScreenModule.createScreen().place(with: nextPushedInFlow)
            
        case .foodOnboarding:
            showFoodOnboardingFlow()
            
        case .onboarding:
            showOnboardingFlow()
            
        case .signup:
            showSignupFlow()
            
        case .strangeFlow:
            StrangeFlow().start(with: nextPushedInFlow)
        
        case .onTheFly:
            showOnTheFlyFlow()
            
        case .survey:
            showSurveyFlow()
            
        case .windowTransition:
            ChooseWindowTransitionFlow().start(with: rootOfApplicationWindow(using: .push))
            
        case .searchAndTrack:
            SearchAndTrackFlow().start(with: nextPresentedInFlow?.withDismissibleNavigationEmbedding())
            
        case .myDay:
            MyDayFlow().start(with: nextPushedInFlow)
            
        case .login:
            LoginScreenModule
                .createScreen()
                .observeOutput { [ weak self] _ in self?.unwind() }
                .place(with: nextPushedInFlow)
            
        case .pageController:
            showPageController()
            
        case .flowDeepStart:
            OnboardingFlow(option: .deepStart(stage: .notifications))
                .start(with: nextPushedInFlow(animated: false))
        }
    }
    
    private func showPageController() {
        PageControllerFlow()
            .observeOutput({ [weak self] output in
                switch output {
                    
                case .didFinish:
                    self?.unwind()
                }
                
            })
            .start(with: nextPresentedInFlow?.withPageEmbedding())
    }
    
    private func showCounterScreen() {
        CounterScreenModule.createScreen(with: CounterScreenModule.State(title: "How many?"))
            .observeOutput { [weak self] output in
                if output == .didTapNext {
                    self?.unwind()
                }
            }
            .place(with: nextPushedInFlow)
    }
    
    private func showSearchScreen() {
        SearchScreenModule<Food>
            .createScreen(configure: { searchStore in
                searchStore.getSearchResults = Food.getFoods
            })
            .observeOutput({ [weak self] output in
                switch output {
                    
                case .didSelectItem:
                    self?.unwind()
                }
            })
            .place(with: nextPushedInFlow)
    }
    
    private func showFoodOnboardingFlow() {
        FoodOnboardingFlow()
            .observeOutput { [weak self] _ in
                self?.unwind()
            }
            .start(with: nextPresentedInFlow?.withDismissibleNavigationEmbedding())
    }
    
    private func showOnboardingFlow() {
        OnboardingFlow()
            .observeOutput { [weak self] output in
                switch output {
                case .didFinish:
                    self?.unwind()
                }
            }
            .start(with: nextPresentedInFlow?.withDismissibleNavigationEmbedding())
    }
    
    private func showSignupFlow() {
        SignupFlow()
            .observeOutput { [weak self] _ in
                self?.unwind()
            }
            .start(with: nextPushedInFlow)
    }
    
    private func showOnTheFlyFlow() {
        FoodOnboardingFlow()
            .observeOutput { [weak self] output in
                switch output {
                    
                case .didFinish:
                    let textState = TextScreenModule.State(title: "Wo0t!", description: "Welcome to the machine!", buttons: ["Okay!"])
                    TextScreenModule.createScreen(with: textState)
                        .observeOutput { [weak self] output in
                            switch output {
                                
                            case .didTapButton:
                                self?.unwind()
                            }
                        }
                        .place(with: self?.nextPresentedInFlow)
                }
            }
            .start(with: nextPushedInFlow)
    }
    
    private func showSurveyFlow() {
        SurveyFlow.favorites
            .observeOutput { [weak self] output in
                switch output {
                case .didFinish(responses: let responses):
                    dump(responses)
                    self?.unwind()
                }
            }
            .start(with: nextPresentedInFlow?.withNavigationEmbedding())
    }
    
    private func showSplitViewFlow() {
        SplitViewFlow()
            .observeOutput({ output in
                switch output {
                
                case .didPressDone:
                    SampleCatalogFlow().start(with: rootOfApplicationWindow(using: .slide(from: .left))?.withNavigationEmbedding())
                }
            })
            .start(with: rootOfApplicationWindow(using: .slide(from: .top)))
    }
    
}
