//
// ==----------------------------------------------------------------------== //
//
//  CounterStoreTests.swift
//
//  Created by Steven Grosmark on 10/5/19.
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
import LassoTestUtilities
@testable import Lasso_Example

class CounterStoreTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<CounterStore>()

    override func setUp() {
        super.setUp()
        store = CounterStore()
        XCTAssertEqual(store.state.counter, 0)
    }

    func test_IncrementDecrement() {
        // when - tap + 3x
        for _ in 0..<3 {
            store.dispatchAction(.didTapIncrement)
        }
        
        // then - counter should be 3
        XCTAssertStateEquals(updatedMarker { state in
            state.counter = 3
        })
        
        // when - tap decrement
        store.dispatchAction(.didTapDecrement)
        
        // then - counter should go down
        XCTAssertStateEquals(updatedMarker { state in
            state.counter = 2
        })
        
        // sanity check no outputs generated
        XCTAssertOutputs([])
    }
    
    func test_Decrement_Clamping() {
        // when
        store.dispatchAction(.didTapDecrement)
        
        // then - don't go negative
        XCTAssertEqual(store.state.counter, 0)
    }
    
    func test_Next() {
        store.dispatchAction(.didTapNext)
        XCTAssertOutputs([.didTapNext])
    }

}
