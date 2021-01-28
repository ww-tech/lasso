//
// ==----------------------------------------------------------------------===//
//
//  MyDayTests.swift
//
//  Created by Trevor Beasty on 10/17/19.
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

class MyDayTestsWithDeepInjection: XCTestCase {

    var myDayController: MyDayController!
    var calendarController: CalendarController!
    var dailyLogController: DailyLogController!
    var cardsController: MyDayCardsController!
    
    var user: User!

    typealias CalendarState = CalendarScreenModule.State
    typealias DailyLogState = DailyLogViewModule.ViewState
    typealias CardsState = MyDayCardsScreenModule.State

    typealias DailyLogServiceRequest = (date: Date, userId: String, completion: (Result<DailyLog, Error>) -> Void)
    typealias CardsRequest = (date: Date, completion: (Result<[String], Error>) -> Void)
    
    var dailyLogRequests: [DailyLogServiceRequest] = []
    var cardsRequests: [CardsRequest] = []

    private func setUp(date: Date) throws {
        super.setUp()
        
        self.myDayController = MyDayController(date: date)
        self.user = User(id: "def456", program: .C)
        
        myDayController.dailyLogScreenFactory = screenFactory(configure: { dailyLogStore in
            dailyLogStore.getDailyLog = { (date, userId, completion) in
                self.dailyLogRequests.append((date, userId, completion))
            }
            dailyLogStore.user = self.user
        })
        
        myDayController.cardsScreenFactory = screenFactory(configure: { myDayCardsStore in
            myDayCardsStore.getCards = { date, completion in
                self.cardsRequests.append((date, completion))
            }
        })
        
        // to trigger 'viewDidLoad', where child setup is performed
        _ = myDayController.view
        
        calendarController = try myDayController.firstChildOfType()
        dailyLogController = try myDayController.firstChildOfType()
        cardsController = try myDayController.firstChildOfType()
    }

    override func tearDown() {
        myDayController = nil
        calendarController = nil
        dailyLogController = nil
        cardsController = nil
        dailyLogRequests = []
        cardsRequests = []
        super.tearDown()
    }

    func test_DateSelection_UpdatesDailyLogAndArticles() throws {
        // given
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.month = 1
        dateComponents.year = 2000
        guard let initialDate = Calendar.current.date(from: dateComponents) else { return XCTFail("could not create date") }
        try setUp(date: initialDate)
        self.dailyLogRequests = []
        self.cardsRequests = []

        // when
        guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: initialDate) else { return XCTFail("could not create next date") }
        calendarController.store.dispatchAction(.didSelectDate(nextDate))

        // then
        XCTAssertEqual(dailyLogRequests.count, 1)
        XCTAssertEqual(dailyLogRequests[0].date, nextDate)
        XCTAssertEqual(dailyLogRequests[0].userId, "def456")
        XCTAssertTrue(dailyLogController.state.isLoading)
        
        XCTAssertEqual(cardsRequests.count, 1)
        XCTAssertEqual(cardsRequests[0].date, nextDate)
        XCTAssertEqual(cardsController.state.phase, .busy)

        // when
        let dailyLog = DailyLog(program: .C, caloriesConsumed: 1, caloriesRemaining: 2, stepsTaken: 3)
        dailyLogRequests[0].completion(.success(dailyLog))
        
        let cards = ["A"]
        cardsRequests[0].completion(.success(cards))

        // then
        let text = "program: C\ncalories consumed: 1\ncalories remaining: 2\nsteps taken: 3"
        XCTAssertEqual(dailyLogController.state, DailyLogState(text: text, isLoading: false))
        
        XCTAssertEqual(cardsController.state, CardsState(cards: cards, phase: .idle))
    }

}

class MyDayTestsWithShallowInjection: XCTestCase {

    var myDayController: MyDayController!
    var mockCalendarScreen: MockScreen<CalendarScreenModule>!
    var mockCardsScreen: MockScreen<MyDayCardsScreenModule>!
    var mockDailyLogScreen: MockScreen<DailyLogScreenModule>!

    private func setUp(date: Date) throws {
        super.setUp()
        
        self.myDayController = MyDayController(date: date)
        mockCalendarScreen = MockScreen<CalendarScreenModule>()
        mockCardsScreen = MockScreen<MyDayCardsScreenModule>()
        mockDailyLogScreen = MockScreen<DailyLogScreenModule>()
        
        myDayController.calendarScreenFactory = mockScreenFactory(mockScreen: mockCalendarScreen)
        myDayController.cardsScreenFactory = mockScreenFactory(mockScreen: mockCardsScreen)
        myDayController.dailyLogScreenFactory = mockScreenFactory(mockScreen: mockDailyLogScreen)
        
        // to trigger 'viewDidLoad', where child setup is performed
        _ = myDayController.view
    }

    override func tearDown() {
        myDayController = nil
        mockCalendarScreen = nil
        mockDailyLogScreen = nil
        mockCardsScreen = nil
        super.tearDown()
    }

    func test_DateSelection_UpdatesDailyLogAndArticles() throws {
        // given
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.month = 1
        dateComponents.year = 2000
        guard let initialDate = Calendar.current.date(from: dateComponents) else { return XCTFail("could not create date") }
        try setUp(date: initialDate)

        // then
        XCTAssertEqual(mockCardsScreen.mockStore?.dispatchedActions, [.updateForDate(date: initialDate)])
        XCTAssertEqual(mockDailyLogScreen.mockStore?.dispatchedActions, [.updateForDate(initialDate)])
        
        // when
        guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: initialDate) else { return XCTFail("could not create next date") }
        mockCalendarScreen.mockStore?.mockUpdate { $0.selectedDate = nextDate }
        
        // then
        XCTAssertEqual(mockCardsScreen.mockStore?.dispatchedActions, [.updateForDate(date: initialDate),
                                                                      .updateForDate(date: nextDate)])
        
        XCTAssertEqual(mockDailyLogScreen.mockStore?.dispatchedActions, [.updateForDate(initialDate),
                                                                         .updateForDate(nextDate)])
    }

}
