//
// ==----------------------------------------------------------------------== //
//
//  FoodOnboardingTests.swift
//
//  Created by Trevor Beasty on 7/16/19.
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
@testable import Lasso_Example

class FoodOnboardingTests: FlowTestCase {

    var flow: FoodOnboardingFlow!

    override func setUp() {
        super.setUp()
        flow = FoodOnboardingFlow()
    }

    override func tearDown() {
        flow = nil
        super.tearDown()
    }

    func test() throws {
        typealias State = TextScreenModule.State
        
        // flow start
        let welcomeController: TextViewController = try assertRoot(
            of: navigationController,
            when: { flow.start(with: root(of: navigationController)) }
        )

        XCTAssertEqual(welcomeController.store.state, State(title: "Welcome",
                                                            description: "We just need a little info to get you going...",
                                                            buttons: ["Next"]))

        // press next on welcome screen
        let notificationsController: TextViewController = try assertPushed(
            after: welcomeController,
            when: { welcomeController.store.dispatchAction(.didTapButton(0)) }
        )

        XCTAssertEqual(notificationsController.store.state, State(title: "Notifications",
                                                                  description: "Enable Notifications for the smoothest experience...",
                                                                  buttons: ["Next"]))

        // press next on notifications screen
        let finishController: TextViewController = try assertPushed(
            after: notificationsController,
            when: { notificationsController.store.dispatchAction(.didTapButton(0)) }
        )

        XCTAssertEqual(finishController.store.state, State(title: "All set",
                                                           description: "Ok, let's get started!",
                                                           buttons: ["Finish"]))

        // output
        flow.assert(when: { finishController.store.dispatchAction(.didTapButton(0)) },
                    outputs: .didFinish)
    }

}
