//
// ==----------------------------------------------------------------------== //
//
//  VerboseLogging.swift
//
//  Created by Trevor Beasty on 12/10/19.
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

func describeViewControllerHierarchy(_ controller: UIViewController) -> String {
    return modalStack(from: controller.rootController)
        .map({ "<\(describe($0))>" })
        .joined(separator: " --> ")
}

private extension UIViewController {
    
    var rootController: UIViewController {
        var root = self
        while let presenting = root.presentingViewController {
            root = presenting
        }
        return root
    }
    
}

private func modalStack(from controller: UIViewController) -> [UIViewController] {
    var stack = [controller]
    var current = controller
    while let presented = current.presentedViewController {
        stack.append(presented)
        current = presented
    }
    return stack
}

private func describe(_ controller: UIViewController) -> String {
    let embedded: [UIViewController]
    if let navigationController = controller as? UINavigationController {
        embedded = navigationController.viewControllers
    }
    else {
        embedded = []
    }
    if embedded.isEmpty {
        return className(controller)
    }
    else {
        let embeddedDescription = embedded
            .map({ return className($0) })
            .joined(separator: ", ")
        return "\(className(controller)) : [\(embeddedDescription)]"
    }
}

private func className<A>(_ value: A) -> String {
    return String(describing: type(of: value))
}
