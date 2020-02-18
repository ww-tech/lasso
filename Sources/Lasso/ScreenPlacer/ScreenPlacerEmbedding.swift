//
//===----------------------------------------------------------------------===//
//
//  ScreenPlacerEmbedding.swift
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

/// Mechanism for overriding default UIKit containers with more specific types with respect to
/// the build-in screen placing utilities.
public enum ScreenPlacerEmbedding {
    
    /// Makes the default navigation controller.
    public static var makeNavigationController: () -> UINavigationController = UINavigationController.init
    
    /// Makes the default 'dismissible' navigation controller.
    public static var makeDismissible: (UINavigationController) -> Void = { navigationController in
        guard let rootViewController = navigationController.viewControllers.first else { return }
        if rootViewController.navigationItem.leftBarButtonItem == nil {
            let button = UIBarButtonItem(barButtonSystemItem: .done, target: navigationController, action: #selector(navigationController.dismissController))
            rootViewController.navigationItem.leftBarButtonItem = button
        }
    }
    
    /// Makes the default tab bar controller.
    public static var makeTabBarController: () -> UITabBarController = UITabBarController.init
    
    /// Makes the default page controller.
    public static var makePageController: () -> UIPageViewController = UIPageViewController.init
    
}

extension UIViewController {
    @objc fileprivate func dismissController() {
        dismiss(animated: true, completion: nil)
    }
}
