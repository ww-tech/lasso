//
// ==----------------------------------------------------------------------== //
//
//  MockableTests.swift
//
//  Created by Steven Grosmark on 12/11/19.
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
@testable import Lasso

#if swift(>=5.1)
class MockableTests: XCTestCase {
    
    struct Group {
        let name: String
        let value: Int
    }
    
    enum GlobalStuff {
        
        @Mockable static var number: Int = 42
        @Mockable static private(set) var staticFunc: () -> String = { "real" }
        @Mockable static private(set) var group: Group = Group(name: "fizz", value: 1)
        
    }
    
    override func setUp() {
        super.setUp()
        GlobalStuff.number = 42
    }
    
    override class func tearDown() {
        GlobalStuff.$number.reset()
        GlobalStuff.$staticFunc.reset()
        GlobalStuff.$group.reset()
        super.tearDown()
    }

    func test_mocking() {
        // given - un-mocked things
        XCTAssertEqual(GlobalStuff.number, 42)
        XCTAssertEqual(GlobalStuff.staticFunc(), "real")
        XCTAssertEqual(GlobalStuff.group.name, "fizz")
        XCTAssertEqual(GlobalStuff.group.value, 1)
        
        // when - apply mock values
        GlobalStuff.$number.mock(with: 999)
        GlobalStuff.$staticFunc.mock(with: { "fake" })
        GlobalStuff.$group.mock(with: Group(name: "buzz", value: 3))
        
        // then - mockables should vend mock values
        XCTAssertEqual(GlobalStuff.number, 999)
        XCTAssertEqual(GlobalStuff.staticFunc(), "fake")
        XCTAssertEqual(GlobalStuff.group.name, "buzz")
        XCTAssertEqual(GlobalStuff.group.value, 3)
        
        // when - reset mockables
        GlobalStuff.$number.reset()
        GlobalStuff.$staticFunc.reset()
        GlobalStuff.$group.reset()
        
        // then - mockables should vend real values
        XCTAssertEqual(GlobalStuff.number, 42)
        XCTAssertEqual(GlobalStuff.staticFunc(), "real")
        XCTAssertEqual(GlobalStuff.group.name, "fizz")
        XCTAssertEqual(GlobalStuff.group.value, 1)
    }
    
    func test_modifyMockable() {
        // given - un-mocked value
        XCTAssertEqual(GlobalStuff.number, 42)
        
        // when - apply mock value
        GlobalStuff.$number.mock(with: 999)
        
        // then - mockable should vend mock values
        XCTAssertEqual(GlobalStuff.number, 999)
        
        // when - "real" value for mockable changed:
        GlobalStuff.number = 101
        
        // then - mockable should still vend mock value
        XCTAssertEqual(GlobalStuff.number, 999)
        
        // when - reset mockable
        GlobalStuff.$number.reset()
        
        // then - mockable should vend new real value
        XCTAssertEqual(GlobalStuff.number, 101)
        
        // when - "real" value changed while not mocked:
        GlobalStuff.number = 88
        
        // then - mockable should vend new value
        XCTAssertEqual(GlobalStuff.number, 88)
    }
    
    func test_noMockWhenNotTesting() {
        // given - un-mocked value
        XCTAssertEqual(GlobalStuff.number, 42)
        
        // given - force a non-test state
        Testing.active = false
        defer { Testing.active = true }
        
        // when - apply mock value
        GlobalStuff.$number.mock(with: 999)
        
        // then - mockable should still vend un-mocked value
        XCTAssertEqual(GlobalStuff.number, 42)
    }

}

#endif
