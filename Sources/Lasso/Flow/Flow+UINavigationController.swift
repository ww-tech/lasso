//
//===----------------------------------------------------------------------===//
//
//  Flow+UINavigationController.swift
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
//===----------------------------------------------------------------------===//
//

import UIKit

// All flow placement utilities necessarily return optional placers b/c flows are required
// to keep weak references to their placedContext, which such conveniences are built upon.
//
// Failure (nil return value) for these conveniences reflects the fact that the placedContext was deallocated.
// This occurs when the placedContext in unexpectedly removed from the view controller hierarchy.

public extension Flow where RequiredContext: UINavigationController {
    
    var nextPushedInFlow: ScreenPlacer<RequiredContext>? {
        return nextPushedInFlow(animated: true)
    }
    
    /// Push on top of the navigation controller's stack.
    func nextPushedInFlow(animated: Bool = true) -> ScreenPlacer<RequiredContext>? {
        guard let navigationController = context else { return nil }
        return pushed(in: navigationController, animated: animated)
    }
    
    /// Place as the root of the navigation controller, removing all other controllers in the stack
    var rootOfFlow: ScreenPlacer<RequiredContext>? {
        guard let navigationController = context else { return nil }
        return root(of: navigationController)
    }
    
    /// Regress to the navigation controller, removing all controllers following the initial controller
    /// in the navigation controller's stack.
    ///
    /// - Parameter animated: animate the regression
    func unwind(animated: Bool = true) {
        guard let initialController = initialController, let navigationController = context else { return }
        navigationController.popToViewController(initialController, animated: animated)
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: animated, completion: nil)
        }
    }
    
    /// Regress to the controller preceding the initial controller in the navigation controller's stack.
    /// If the initial controller is in the zeroth position, regress to the controller modally preceding
    /// the navigation controller.
    ///
    /// - Parameter animated: animate the regression
    func dismiss(animated: Bool = true) {
        guard let initialController = initialController, let navigationController = context, let initialIndex = navigationController.viewControllers.firstIndex(of: initialController) else { return }
        if initialIndex == 0 {
            if let presenting = navigationController.presentingViewController {
                presenting.dismiss(animated: animated, completion: nil)
            }
            else {
                navigationController.popToRootViewController(animated: animated)
            }
        }
        else {
            navigationController.popToViewController(navigationController.viewControllers[initialIndex - 1], animated: animated)
        }
    }
    
}
