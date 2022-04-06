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
///
/// Key features:
/// 1) a UIWindow which is made 'key and visible'. This is required for lifecycle hooks to work.
/// 2) convenience controllers in the root of the window which cover the most common use cases
///
/// Does **NOT** support async versions of `setUp` and `tearDown`
open class FlowTestCase: XCTestCase {
    
    public var window: UIWindow!
    public var navigationController: UINavigationController!
    public var rootController: UIViewController!
    
    // https://developer.apple.com/documentation/xctest/xctestcase/set_up_and_tear_down_state_in_your_tests
    //
    // setUp:
    // XCTest runs the setup methods once before each test method starts:
    //  setUp() async throws (Xcode 13+) first,
    //  then setUpWithError() (Xcode 11.4+),
    //  then setUp() (Xcode 7.5+).
    //
    // We want to set up the FlowTestCase as early as possible so that
    // subclasses can start to access the helpers and make assertions in
    // their setUp funcs.
    
    #if compiler(>=5.2)
    open override func setUpWithError() throws {
        try super.setUpWithError()
        setUpFlowTestCase()
    }
    #endif
    
    open override func setUp() {
        super.setUp()
        setUpFlowTestCase()
    }
    
    // tearDown:
    // XCTest runs the teardown methods once after each test method completes, with
    //  tearDown() first (Xcode 7.5+),
    //  then tearDownWithError() (Xcode 11.4+),
    //  then tearDown() async throws (Xcode 13+).
    //
    // We want to tear down the FlowTestCase as late as possible, since
    // subclasses _might_ depend on these values in their tearDown funcs
    // (Rarely done, but possible to use XCTest assertions in tearDown).
    
    #if compiler(>=5.2)
    open override func tearDownWithError() throws {
        tearDownFlowTestCase()
        try super.tearDownWithError()
    }
    
    #else
    open override func tearDown() {
        tearDownFlowTestCase()
        super.tearDown()
    }
    #endif
    
    private func setUpFlowTestCase() {
        guard window == nil else { return }
        window = UIWindow()
        window.makeKeyAndVisible()
        rootController = UIViewController()
        navigationController = UINavigationController(rootViewController: rootController)
        window.rootViewController = navigationController
        waitForEvents(in: window)
    }
    
    private func tearDownFlowTestCase() {
        window = nil
        navigationController = nil
        rootController = nil
    }
    
}
