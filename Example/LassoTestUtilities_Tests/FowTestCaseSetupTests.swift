//
// ==----------------------------------------------------------------------== //
//
//  FowTestCaseSetupTests.swift
//
//  Created by Steven Grosmark on 04/01/2022
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2022 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import XCTest
import UIKit
@testable import LassoTestUtilities

// MARK: - `setUp` / `tearDown` pair

class FowTestCaseSetupTests: FlowTestCase {
    
    var windowInstance: ObjectIdentifier!
    var navigationControllerInstance: ObjectIdentifier!
    var rootControllerInstance: ObjectIdentifier!
    
    override func setUp() {
        super.setUp()
        XCTAssertNotNil(window)
        XCTAssertNotNil(navigationController)
        XCTAssertNotNil(rootController)
        
        windowInstance = ObjectIdentifier(window)
        navigationControllerInstance = ObjectIdentifier(navigationController)
        rootControllerInstance = ObjectIdentifier(rootController)
    }
    
    override func tearDown() {
        XCTAssertEqual(windowInstance, ObjectIdentifier(window))
        XCTAssertEqual(navigationControllerInstance, ObjectIdentifier(navigationController))
        XCTAssertEqual(rootControllerInstance, ObjectIdentifier(rootController))
        
        super.tearDown()
    }
    
    /// Gratuitous test func needed to invoke `setUp` and `tearDown`
    func test_setupAndTeardown() {
        XCTAssertTrue(true)
    }
}

// MARK: - `setUpWithError` / `tearDownWithError`

#if compiler(>=5.2)
class FowTestCaseSetupWithErrorTests: FlowTestCase {
    
    var windowInstance: ObjectIdentifier!
    var navigationControllerInstance: ObjectIdentifier!
    var rootControllerInstance: ObjectIdentifier!
    
    /// Called before `setUp`
    override func setUpWithError() throws {
        try super.setUpWithError()
        XCTAssertNotNil(window)
        XCTAssertNotNil(navigationController)
        XCTAssertNotNil(rootController)
        
        windowInstance = ObjectIdentifier(window)
        navigationControllerInstance = ObjectIdentifier(navigationController)
        rootControllerInstance = ObjectIdentifier(rootController)
    }
    
    /// Celled after `setUpWithError`
    override func setUp() {
        super.setUp()
        
        XCTAssertEqual(windowInstance, ObjectIdentifier(window))
        XCTAssertEqual(navigationControllerInstance, ObjectIdentifier(navigationController))
        XCTAssertEqual(rootControllerInstance, ObjectIdentifier(rootController))
    }
    
    /// Called before `tearDownWithError`
    override func tearDown() {
        XCTAssertEqual(windowInstance, ObjectIdentifier(window))
        XCTAssertEqual(navigationControllerInstance, ObjectIdentifier(navigationController))
        XCTAssertEqual(rootControllerInstance, ObjectIdentifier(rootController))
        
        super.tearDown()
    }
    
    /// Celled after `tearDown`
    override func tearDownWithError() throws {
        XCTAssertEqual(windowInstance, ObjectIdentifier(window))
        XCTAssertEqual(navigationControllerInstance, ObjectIdentifier(navigationController))
        XCTAssertEqual(rootControllerInstance, ObjectIdentifier(rootController))
        
        try super.tearDownWithError()
    }
    
    /// Gratuitous test func needed to invoke `setUp` and `tearDown`
    func test_setupAndTeardown() {
        XCTAssertTrue(true)
    }
}
#endif
