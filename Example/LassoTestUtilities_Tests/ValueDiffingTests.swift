//
//===----------------------------------------------------------------------===//
//
//  ValueDiffingTests.swift
//
//  Created by Trevor Beasty on 9/9/19.
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

class ValueDiffingTests: XCTestCase {

    struct User {
        let age: Int
        let name: String
    }
    
    func test_0() {
        let value0 = User(age: 0, name: "a")
        let value1 = User(age: 0, name: "b")
        
        let _diff = diff(realized: value0, expected: value1)
        
        XCTAssertEqual(_diff, [Diff(key: "name", type: "String", realized: "a", expected: "b")])
    }
    
    func test_1() {
        let value0 = User(age: 0, name: "a")
        let value1 = User(age: 1, name: "b")
        
        let _diff = diff(realized: value0, expected: value1)
        
        XCTAssertEqual(_diff, [Diff(key: "age", type: "Int", realized: "0", expected: "1"),
                               Diff(key: "name", type: "String", realized: "a", expected: "b")])
    }

}
