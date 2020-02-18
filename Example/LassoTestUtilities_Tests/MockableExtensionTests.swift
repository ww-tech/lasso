//
//===----------------------------------------------------------------------===//
//
//  MockableExtensionTests.swift
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
//===----------------------------------------------------------------------===//
//

import XCTest
import Lasso
import LassoTestUtilities

#if swift(>=5.1)
class MockableExtensionTests: XCTestCase {
    
    @Mockable var number: Int = 1

    func test_mock() {
        // given - initial value
        XCTAssertEqual(number, 1)
        
        // when - apply mock
        mock($number, with: 123)
        
        // then - mocked value
        XCTAssertEqual(number, 123)
    }
    
    func test_mockAgain() {
        // given - initial value
        XCTAssertEqual(number, 1)
        
        // when - apply mock
        mock($number, with: 999)
        
        // then - mocked value
        XCTAssertEqual(number, 999)
    }

}
#endif
