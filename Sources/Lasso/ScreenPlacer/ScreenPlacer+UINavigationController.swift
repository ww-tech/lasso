//
// ==----------------------------------------------------------------------== //
//
//  ScreenPlacer+UINavigationController.swift
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

/// Place some controller as the root of the navigation controller.
///
/// - Parameters:
///   - navigationController: the navigation controller to be placed into
///   - onDidPlaceEmbedded: a closure to be executed immediately following placement of the child into the navigation controller
/// - Returns: the placer into the navigation controller
public func navigationEmbedding(_ navigationController: UINavigationController = ScreenPlacerEmbedding.makeNavigationController(),
                                onDidPlaceEmbedded: @escaping () -> Void = { }) -> ScreenPlacer<UINavigationController> {
    
    let place = { (navigationController: UINavigationController, toPlace: UIViewController) in
        navigationController.viewControllers = [toPlace]
    }
    
    return makeEmbeddingPlacer(into: navigationController, place: place, onDidPlaceEmbedded: onDidPlaceEmbedded)
}

extension ScreenPlacer {
    
    /// Compose a navigation embedding into an existing placer.
    ///
    /// - Parameter navigationController: the navigation controller to be placed into
    /// - Returns: the placer into the navigation controller
    public func withNavigationEmbedding(_ navigationController: UINavigationController = ScreenPlacerEmbedding.makeNavigationController()) -> ScreenPlacer<UINavigationController> {
        
        return navigationEmbedding(navigationController, onDidPlaceEmbedded: {
            self.place(navigationController)
        })
    }
    
    /// Compose a dismissible navigation embedding into an existing placer.
    ///
    /// - Parameter navigationController: the dismissible navigation controller to be placed into
    /// - Returns: the placer into the dismissible navigation controller
    public func withDismissibleNavigationEmbedding(_ navigationController: UINavigationController = ScreenPlacerEmbedding.makeNavigationController()) -> ScreenPlacer<UINavigationController> {
        
        return navigationEmbedding(navigationController, onDidPlaceEmbedded: {
            self.place(navigationController)
            ScreenPlacerEmbedding.makeDismissible(navigationController)
        })
    }
    
}

// MARK: - Instance Placement

/// Push some controller on top of the navigation stack.
///
/// - Parameter navigationController: the navigation controller to be pushed onto
/// - Returns: the placer into the navigation controller
public func pushed<NavigationController: UINavigationController>(in navigationController: NavigationController, animated: Bool = true) -> ScreenPlacer<NavigationController> {
    
    return makePlacer(base: navigationController) { navigationController, toPlace in
        navigationController.pushViewController(toPlace, animated: animated)
        return navigationController
    }
}

/// Push some controller at the root of the navigation stack, removing all other controllers in the stack.
///
/// - Parameter navigationController: the navigation controller to be placed into
/// - Returns: the placer into the navigation controller
public func root<NavigationController: UINavigationController>(of navigationController: NavigationController, animated: Bool = false) -> ScreenPlacer<NavigationController> {
    
    return makePlacer(base: navigationController) { navigationController, toPlace in
        navigationController.setViewControllers([toPlace], animated: animated)
        return navigationController
    }
}
