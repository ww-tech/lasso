//
// ==----------------------------------------------------------------------== //
//
//  FlowTestCase.swift
//
//  Created by Trevor Beasty on 8/7/19.
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

import XCTest
import UIKit

/// Provides conveniences for Flow unit testing.
/// Key features:
/// 1) a UIWindow which is made 'key and visible'. This is required for lifecycle hooks to work.
/// 2) convenience controllers in the root of the window which cover the most common use cases
open class FlowTestCase: XCTestCase {
    
    public private(set) var window: UIWindow!
    public private(set) var navigationController: UINavigationController!
    public private(set) var rootController: UIViewController!
    
    open override func setUpWithError() throws {
        try super.setUpWithError()
        setUpFlowTestCase()
    }
    
    open override func setUp() {
        super.setUp()
        setUpFlowTestCase()
    }
    
    private func setUpFlowTestCase() {
        guard window == nil else { return }
        window = UIWindow()
        window.makeKeyAndVisible()
        rootController = UIViewController()
        navigationController = UINavigationController(rootViewController: rootController)
        window.rootViewController = navigationController
        waitForEvents(in: window)
        
        addTeardownBlock { [weak self] in
            self?.window = nil
            self?.navigationController = nil
            self?.rootController = nil
        }
    }
    
}
