//
// ==----------------------------------------------------------------------== //
//
//  ConvenienceTests.swift
//
//  Created by Russell Savage on 10/11/22
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
import LassoTestUtilities
@testable import Lasso_Example

class ConvenienceTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<LoginScreenStore>()
    
    func test_asyncConvenience_fails() {
        XCTExpectFailure("This test is expected to fail on timeout")
        wait(for: [expectationAsync({ false })], timeout: 0.0001)
    }
    
    func test_asyncConvenience_succeeds() {
        var outsideIter = 0
        wait(for: [expectationAsync({
            outsideIter += 1
            return outsideIter >= 10
        })], timeout: 1.0)
    }
}
