//
// ==----------------------------------------------------------------------== //
//
//  ScreenPlacer+UITabBarController.swift
//
//  Created by Trevor Beasty on 6/12/19.
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

// MARK: - Embedding

/// Place many controllers as the controllers for the tab controller.
///
/// - Parameters:
///   - tabBarController: the tab controller to be placed into
///   - tabsCount: the desired number of tabs
///   - onDidPlaceEmbedded: a closure to be executed immediately following placement of the children into the tab controller
/// - Returns: the placers into the tab controller; equal in count to the 'tabsCount' arg; indices correspond to those of the tab controller's 'viewControllers'
public func tabBarEmbedding(_ tabBarController: UITabBarController = ScreenPlacerEmbedding.makeTabBarController(),
                            tabsCount: Int,
                            onDidPlaceEmbedded: @escaping () -> Void = { }) -> [ScreenPlacer<UITabBarController>] {
    
    let place = { (tabBarController: UITabBarController, manyToPlace: [UIViewController]) in
        tabBarController.viewControllers = manyToPlace
    }
    
    return makeEmbeddingPlacers(into: tabBarController, count: tabsCount, place: place, onDidPlaceEmbedded: onDidPlaceEmbedded)
}

extension ScreenPlacer {
    
    /// Compose a tab controller embedding into an existing placer.
    ///
    /// - Parameters:
    ///   - tabBarController: the tab controller to be placed into
    ///   - tabsCount: the desired number of tabs
    /// - Returns: the placers into the tab controller; equal in count to the 'tabsCount' arg; indices correspond to those of the tab controller's 'viewControllers'
    public func withTabBarEmbedding(_ tabBarController: UITabBarController = ScreenPlacerEmbedding.makeTabBarController(),
                                    tabsCount: Int) -> [ScreenPlacer<UITabBarController>] {
        
        return tabBarEmbedding(tabBarController, tabsCount: tabsCount, onDidPlaceEmbedded: {
            self.place(tabBarController)
        })
    }
    
}
