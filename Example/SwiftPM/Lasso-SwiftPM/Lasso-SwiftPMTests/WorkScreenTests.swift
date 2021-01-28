//
// ==----------------------------------------------------------------------== //
//
//  WorkScreenTests.swift
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
// ==----------------------------------------------------------------------== //
//

import XCTest
import LassoTestUtilities
@testable import Lasso_SwiftPM

class WorkScreenTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<WorkStore>()

    override func setUp() {
        super.setUp()
        store = WorkStore()
    }

    func test_initialState() {
        XCTAssertStateEquals(WorkScreenModule.defaultInitialState)
        XCTAssertTrue(store.state.work.isEmpty)
    }
    
    func test_workButton() {
        // when
        store.dispatchAction(.didTapWork)
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.work = ["work"]
        })
        XCTAssertOutputs([])
        
        // when
        store.dispatchAction(.didTapWork)
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.work = ["work", "work"]
        })
        XCTAssertOutputs([])
    }
    
    func test_workedEnough() {
        // when
        for _ in 0..<5 {
            store.dispatchAction(.didTapWork)
        }
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.work = ["work", "work", "work", "work", "work"]
        })
        XCTAssertOutputs([.didWorkEnough])
    }
    
    func test_rested() {
        // when
        store.dispatchAction(.didTapWork)
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.work = ["work"]
        })
        XCTAssertOutputs([])
        
        // when
        store.dispatchAction(.didGetSomeRest)
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.work = []
        })
        XCTAssertOutputs([])
    }

}
