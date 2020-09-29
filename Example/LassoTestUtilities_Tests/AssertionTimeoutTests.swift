//
//===----------------------------------------------------------------------===//
//
//  AssertionTimeoutTests.swift
//
//  Created by Steven Grosmark on 9/25/20
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

import XCTest
@testable import LassoTestUtilities

class AssertionTimeoutDefaultTests: XCTestCase {
    
    func test_default() throws {
        XCTAssertEqual(lassoAssertionTimeout, 1)
        
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc = LifeCycleController()
        let nav = UINavigationController()
        window.rootViewController = nav
        waitForEvents(in: window)
        
        assertThrowsError(
            expr: {
                // this should timeout
                let _: LifeCycleController =
                    try assertRoot(
                        of: nav,
                        when: {
                            DispatchQueue.main.async {
                                Thread.sleep(forTimeInterval: 1.5)
                            }
                            DispatchQueue.main.async {
                                Thread.sleep(forTimeInterval: 0.1)
                            }
                            nav.viewControllers = [vc]
                        },
                        failTest: silent
                    )
            },
            eval: {
                switch $0 {
                case WaitError.timedOut: ()
                default: unexpectedErrorType()
                }
            }
        )
    }

}

class AssertionTimeoutOverrideTests: XCTestCase, AssertionTimeoutOverride {
    
    var defaultLassoAssertionTimeout: TimeInterval { 2 }
    
    func test_override() throws {
        XCTAssertEqual(lassoAssertionTimeout, 2)
        
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc = LifeCycleController()
        let nav = UINavigationController()
        window.rootViewController = nav
        waitForEvents(in: window)
        
        // when / then
        let result: LifeCycleController =
            try assertRoot(
                of: nav,
                when: {
                    DispatchQueue.main.async {
                        Thread.sleep(forTimeInterval: 1.5)
                    }
                    DispatchQueue.main.async {
                        Thread.sleep(forTimeInterval: 0.1)
                    }
                    nav.viewControllers = [vc]
                }
            )
        XCTAssertTrue(result === vc)
    }
    
}
