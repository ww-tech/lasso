//
//===----------------------------------------------------------------------===//
//
//  RestScreenTests.swift
//
//  Created by Steven Grosmark on 1/6/20.
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
import LassoTestUtilities
@testable import Lasso_SwiftPM

class RestScreenTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<RestStore>()
    
    override func setUp() {
        super.setUp()
        store = RestStore()
    }
    
    func test_rest() {
        // given
        XCTAssertStateEquals(RestScreenModule.State())
        
        // when
        store.dispatchAction(.didTapBackToWork)
        
        // then
        XCTAssertOutputs([.didRestEnough])
    }
    
}
