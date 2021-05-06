//
// ==----------------------------------------------------------------------== //
//
//  SurveyFlowTests.swift
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

class SurveyFlowTests: FlowTestCase {
    
    var flow: SurveyFlow!
    
    override func tearDown() {
        flow = nil
        super.tearDown()
    }
    
    private func setUp(questions: [String]) {
        flow = SurveyFlow(questions: questions)
    }
    
    func test_NoPrize() throws {
        typealias ViewState = MakeListViewModule.ViewState
        
        // setup
        setUp(questions: ["question0"])
        flow.getPrize = { _, completion in completion(nil) }
        let navigationController = UINavigationController()
        
        // start flow
        let question0Controller: MakeListViewController = try assertRoot(
            of: navigationController,
            when: { flow.start(with: root(of: navigationController)) }
        )
        
        XCTAssertEqual(question0Controller.store.state, ViewState(header: "question0",
                                                                  placeholder: "",
                                                                  proposed: nil,
                                                                  submitted: []))
        
        // question screen - answering and submitting
        question0Controller.store.dispatchAction(.didEditProposed("foo"))
        question0Controller.store.dispatchAction(.didPressAdd)
        
        XCTAssertEqual(question0Controller.store.state.proposed, nil)
        XCTAssertEqual(question0Controller.store.state.submitted, ["foo"])
        
        flow.assert(when: { question0Controller.store.dispatchAction(.didPressSubmit) },
                    outputs: .didFinish(responses: ["question0": ["foo"] ], prize: nil))
    }
    
    func test_Prize() throws {
        typealias State = TextScreenModule.State
        
        // setup
        setUp(questions: ["question0"])
        let prize = SurveyFlowModule.Prize(name: "foo",
                                           description: "bar",
                                           dollarValue: 1)
        
        flow.getPrize = { _, completion in
            completion(prize)
        }
        
        // start flow
        let question0Controller: MakeListViewController = try assertRoot(
            of: navigationController,
            when: { flow.start(with: root(of: navigationController)) }
        )
        
        // question screen - submit
        let prizeController: TextViewController = try assertPushed(
            after: question0Controller,
            when: { question0Controller.store.dispatchAction(.didPressSubmit) }
        )
        
        XCTAssertEqual(prizeController.store.state, State(title: "You won a foo!!",
                                                          description: "bar\n\nA $1 value!!",
                                                          buttons: ["OMG!!"]))
        
        // prize screen - press button
        flow.assert(when: { prizeController.store.dispatchAction(.didTapButton(0)) },
                    outputs: .didFinish(responses: ["question0": []], prize: prize))
    }
    
}
