//
// ==----------------------------------------------------------------------== //
//
//  ScreenPlacer+UIWindow.swift
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
    
// MARK: - Instance Placement

/// Place some controller as the root of the window with an optional animation. The next context
/// is the controller which is placed.
///
/// An exhaustive variety of built-in transition animations are available here. Some transitions reflect typical
/// UIKit transitions (e.g. pushing onto a navigation controller). Use of these transitions can drastically decrease
/// the complexity of view controller hierarchies while maintaining familiar transition animations. This is achieved by
/// setting some 'next' controller as the root of the window with the desired transition, as opposed to placing that
/// 'next' controller on top of some existing view controller hierarchy.
///
/// - Parameters:
///   - window: the window to be placed into
///   - transition: the transition to be animated
/// - Returns: the placer
public func root(of window: UIWindow, using transition: UIWindow.Transition? = nil) -> ScreenPlacer<UIViewController> {
    
    return makePlacer(base: window) { window, toPlace in
        if let transition = transition {
            window.setRootViewController(toPlace, with: transition)
        }
        else {
            window.rootViewController = toPlace
        }
        return toPlace
    }
}

/// Place some controller as the root of the application window with an optional animation. The next context
/// is the controller which is placed. This call fails if the application window cannot be found.
///
/// - Parameters:
///   - transition: the transition to be animated
/// - Returns: the placer
public func rootOfApplicationWindow(using transition: UIWindow.Transition? = nil) -> ScreenPlacer<UIViewController>? {
    
    guard let window = UIApplication.shared.keyWindow else { return nil }
    return root(of: window, using: transition)
}
