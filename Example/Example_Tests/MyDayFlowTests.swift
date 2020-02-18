//
//===----------------------------------------------------------------------===//
//
//  MyDayFlowTests.swift
//
//  Created by Trevor Beasty on 10/18/19.
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

class MyDayFlowTestsWithDeepInjection: FlowTestCase {

    var flow: MyDayFlow!
    
    var cardsRequests: [(date: Date, completion: (Result<[String], Error>) -> Void)] = []
    
    override func setUp() {
        super.setUp()
        flow = MyDayFlow()
        
        flow.createMyDay = { (date: Date) -> MyDayController in
            let myDayController = MyDayController(date: date)
            
            myDayController.cardsScreenFactory = screenFactory(configure: { cardsStore in
                cardsStore.getCards = { date, completion in
                    self.cardsRequests.append((date, completion))
                }
            })
            
            return myDayController
        }
    }
    
    override func tearDown() {
        flow = nil
        cardsRequests = []
        super.tearDown()
    }
    
    func test_CardSelection() throws {
        let myDayController: MyDayController = try assertRoot(
            of: navigationController,
            when: { flow.start(with: root(of: navigationController)) }
        )
        
        let cards = ["A"]
        cardsRequests[0].completion(.success(cards))
        
        let cardsController: MyDayCardsController = try myDayController.firstChildOfType()
        let cardsDetailController: TextViewController = try assertPushed(
            after: myDayController,
            when: { cardsController.store.dispatchAction(.didSelectCard(idx: 0)) }
        )
        XCTAssertEqual(cardsDetailController.state.title, "A")
    }

}

class MyDayFlowTestsWithShallowInjection: FlowTestCase {

    var flow: MyDayFlow!
    var mockCardsScreen: MockScreen<MyDayCardsScreenModule>!
    
    override func setUp() {
        super.setUp()
        flow = MyDayFlow()
        mockCardsScreen = MockScreen<MyDayCardsScreenModule>()
        
        flow.createMyDay = { (date: Date) -> MyDayController in
            let myDayController = MyDayController(date: date)
            myDayController.cardsScreenFactory = mockScreenFactory(mockScreen: self.mockCardsScreen)
            return myDayController
        }
    }
    
    override func tearDown() {
        flow = nil
        mockCardsScreen = nil
        super.tearDown()
    }
    
    func test_CardSelection() throws {
        let myDayController: MyDayController = try assertRoot(
            of: navigationController,
            when: { flow.start(with: root(of: navigationController)) }
        )
        
        let cardsDetailController: TextViewController = try assertPushed(
            after: myDayController,
            when: { mockCardsScreen.mockStore?.dispatchMockOutput(.didSelectCard(card: "A")) }
        )
        XCTAssertEqual(cardsDetailController.state.title, "A")
    }

}
