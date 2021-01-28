//
// ==----------------------------------------------------------------------== //
//
//  Flow+UIViewController.swift
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

// Convenience for upcasting a ScreenPlacer generic on some UIViewController subclass
//  to a ScreenPlacer<UIViewController>.
// This allows for starting a Flow<UIViewController> in a ScreenPlacer<UINavigationController>,
//  for example - a situation where the Flow's placement requirement is less specific than
//  the provided ScreenPlacer.
public extension Flow where RequiredContext == UIViewController {
    
    /// Starts the flow
    ///
    /// Places the controller returned by 'createInitialController' with the provided placer.
    /// Handles ARC considerations relative to the Flow, creating a strong reference from
    /// the initial controller to the Flow.
    ///
    /// - Parameter placer: ScreenPlacer with 'placedContext' that is a subclass of UIViewController
    func start<Placed>(with placer: ScreenPlacer<Placed>?) where Placed: UIViewController {
        
        let upcastedPlacer = placer.map { placer in
            ScreenPlacer<UIViewController> { toPlace in
                return placer.place(toPlace) as UIViewController
            }
        }
        
        start(with: upcastedPlacer)
    }
    
}

// Utilities available to a Flow that has specified a placedContext that is a UIViewController.
// B/c all contexts must subclass UIViewController, this will be available to all flows.
public extension Flow where RequiredContext: UIViewController {
    
    /// Modal presentation into the modally top-most position (relative to the initialController).
    var nextPresentedInFlow: ScreenPlacer<UIViewController>? {
        guard let context = context else { return nil }
        return presented(on: context.topController)
    }
    
    /// Regress to the initial controller, dismissing all presented controllers.
    ///
    /// - Parameter animated: animate the regression
    func unwind(animated: Bool = true) {
        guard let context = context, context.presentedViewController != nil else { return }
        context.dismiss(animated: animated, completion: nil)
    }
    
    /// Regress to the view controller modally preceding the initialController. If no such controller exists,
    /// regress to the initial controller.
    ///
    /// - Parameter animated: animate the regression
    func dismiss(animated: Bool = true) {
        guard let context = context else { return }
        if let presenting = context.presentingViewController {
            presenting.dismiss(animated: animated, completion: nil)
        }
        else if context.presentedViewController != nil {
            context.dismiss(animated: animated, completion: nil)
        }
    }
    
}

private extension UIViewController {
    
    var topController: UIViewController {
        var topController: UIViewController = self
        while let presented = topController.presentedViewController {
            topController = presented
        }
        return topController
    }
    
}
