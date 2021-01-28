//
// ==----------------------------------------------------------------------== //
//
//  TabsFlow.swift
//
//  Created by Steven Grosmark on 5/10/19.
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

class TabsFlow: Flow<NoOutputFlow> {
    
    override func createInitialController() -> UIViewController {
        
        let tabBarController = UITabBarController()
        let tabBarPlacers = tabBarEmbedding(tabBarController, tabsCount: 4)
        
        let circleState = CounterScreenModule.State(counter: 0, style: .dark)
        CounterScreenModule.createScreen(with: circleState)
            .setUpController { $0.tabBarItem = UITabBarItem(title: "Circles", image: UIImage(named: "circle"), tag: 0) }
            .place(with: tabBarPlacers[0])
        
        for (index, name) in [(1, "Two"), (2, "Three")] {
            let textState = TextScreenModule.State(title: "Tab #\(index + 1)", description: "text text text.")
            TextScreenModule
                .createScreen(with: textState)
                .setUpController { $0.tabBarItem = UITabBarItem(title: name, image: UIImage(named: "square"), tag: index) }
                .place(with: tabBarPlacers[index])
        }
        
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Onboarding", image: UIImage(named: "circle"), tag: 0)
        FoodOnboardingFlow()
            .observeOutput({ [weak self] output in
                switch output {
                case .didFinish:
                    self?.dismiss()
                }
            })
            .start(with: tabBarPlacers[3].withNavigationEmbedding(navigationController))
        
        return tabBarController
    }
    
}
