//
// ==----------------------------------------------------------------------== //
//
//  WorkFlowTests.swift
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
import Lasso
import LassoTestUtilities
@testable import Lasso_SwiftPM

class WorkFlowTests: FlowTestCase {
    
    var flow: WorkFlow!

    override func setUp() {
        super.setUp()
        flow = WorkFlow()
    }

    override func tearDown() {
        flow = nil
        super.tearDown()
    }

    func testExample() throws {
        
        let workController: WorkViewController =
            try assertRoot(
                of: navigationController,
                when: { flow.start(with: root(of: navigationController)) })
        
        let restController: RestViewController =
            try assertPresentation(
                on: navigationController,
                when: {
                    for _ in 0..<5 {
                        workController.store.dispatchAction(.didTapWork)
                    }
                }
            )
        XCTAssertEqual(workController.state.work, ["work", "work", "work", "work", "work"])
        
        try assertDismissal(
            from: restController,
            to: navigationController,
            when: { restController.store.dispatchAction(.didTapBackToWork) }
        )
        XCTAssertEqual(workController.state.work, [])
    }

}
