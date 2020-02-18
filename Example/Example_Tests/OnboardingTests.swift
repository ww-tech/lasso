//
//===----------------------------------------------------------------------===//
//
//  OnboardingTests.swift
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
//===----------------------------------------------------------------------===//
//

import XCTest
import Lasso
import LassoTestUtilities
@testable import Lasso_Example

class OnboardingTests: FlowTestCase {
    
    var flow: OnboardingFlow!
    
    override func setUp() {
        super.setUp()
        flow = OnboardingFlow()
    }
    
    override func tearDown() {
        flow = nil
        super.tearDown()
    }
    
    func test_FullSequence() throws {
        // when / then - start
        let welcomeController: TextViewController = try assertRoot(
            of: navigationController,
            when: { flow.start(with: root(of: navigationController)) },
            onViewDidAppear: { welcomeController in
                XCTAssertEqual(welcomeController.store.state, TextScreenModule.State(title: "Welcome",
                                                                                     description: "We just need a little info to get you going...",
                                                                                     buttons: ["Next"]))
        })
        
        // when / then - tap button 0 on welcome controller
        let nameController: EnterNameViewController = try assertPushed(
            after: welcomeController,
            when: { welcomeController.dispatchAction(.didTapButton(0)) },
            onViewDidAppear: { _, nameController in
                XCTAssertEqual(nameController.store.state, EnterNameScreenModule.State(title: "Enter you name",
                                                                                       name: ""))
                XCTAssertFalse(nameController.store.state.canProceed)
        })

        // when / then - change name on name controller
        nameController.dispatchAction(.didChange("Blob"))

        XCTAssertEqual(nameController.store.state.name, "Blob")
        XCTAssertTrue(nameController.store.state.canProceed)

        // when / then - tap next on name controller
        let counterController: CounterViewController = try assertPushed(
            after: nameController,
            when: { nameController.store.dispatchAction(.didTapNext) },
            onViewDidAppear: { _, counterController in
                XCTAssertEqual(counterController.store.state, CounterScreenModule.State(title: "Rollover points",
                                                                                        counter: 0,
                                                                                        style: .light))
        })

        // when / then - increment on counter controller
        (0..<3).forEach { _ in
            counterController.store.dispatchAction(.didTapIncrement)
        }

        XCTAssertEqual(counterController.store.state.counter, 3)

        // when / then - tap next on counter controller
        let notificationsController: TextViewController = try assertPushed(
            after: counterController,
            when: { counterController.store.dispatchAction(.didTapNext) },
            onViewDidAppear: { _, notificationsController in
                XCTAssertEqual(notificationsController.store.state, TextScreenModule.State(title: "Notifications",
                                                                                           description: "Enable Notifications for the smoothest experience...",
                                                                                           buttons: ["Next", "Start Over"]))
        })

        // when / then - tap button 0 on notifications controller
        let doneController: TextViewController = try assertPushed(
            after: notificationsController,
            when: { notificationsController.store.dispatchAction(.didTapButton(0)) },
            onViewDidAppear: { _, doneController in
                XCTAssertEqual(doneController.store.state, TextScreenModule.State(title: "All set",
                                                                                  description: "Ok, Blob, let's get started!\n\nBy completing this onboarding, you earned 3 rollover points!",
                                                                                  buttons: ["Finish"]))
        })

        // output
        flow.assert(when: { doneController.store.dispatchAction(.didTapButton(0)) },
                    outputs: .didFinish)
    }

    func test_Restart_ClearsName() throws {
        // flow start
        let welcomeController: TextViewController = try assertRoot(
            of: navigationController,
            when: { flow.start(with: root(of: navigationController)) }
        )
        
        // press next on welcome screen
        let nameController0: EnterNameViewController = try assertPushed(
            after: welcomeController,
            when: { welcomeController.store.dispatchAction(.didTapButton(0)) }
        )

        // name screen - edit name then restart
        nameController0.store.dispatchAction(.didChange("Blob"))
        
        try assertPopped(
            from: nameController0,
            to: welcomeController,
            when: { nameController0.store.dispatchAction(.didTapRestart) }
        )

        // proceed to name screen from welcome screen
        let nameController1: EnterNameViewController = try assertPushed(
            after: welcomeController,
            when: { welcomeController.store.dispatchAction(.didTapButton(0)) }
        )
    
        // name should be empty following 'restart' event
        XCTAssertEqual(nameController1.store.state.name, "")
    }
    
}
