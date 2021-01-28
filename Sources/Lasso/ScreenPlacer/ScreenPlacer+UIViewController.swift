//
// ==----------------------------------------------------------------------== //
//
//  ScreenPlacer+UIViewController.swift
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

/// Modally present on some other controller. The next context is the controller which is placed.
///
/// - Parameter controller: the controller to be presented on
/// - Returns: the placer
public func presented(on controller: UIViewController, animated: Bool = true) -> ScreenPlacer<UIViewController> {
    
    return makePlacer(base: controller) { viewController, toPlace in
        viewController.present(toPlace, animated: animated, completion: nil)
        return toPlace
    }
}
