//
// ==----------------------------------------------------------------------== //
//
//  StateObservationTests.swift
//
//  Created by Steven Grosmark on 9/7/19.
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
@testable import Lasso

class StateObservationTests: XCTestCase {
    
    func test_Store_State_Equatable() {
        enum TestModule: StoreModule {
            struct State: Equatable {
                let name: String
                let num: Int
                init(_ name: String, _ num: Int) {
                    self.name = name
                    self.num = num
                }
            }
        }
        typealias State = TestModule.State
        
        // given
        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("A", 2))
        
        var states: [State] = []
        var oldStates: [State?] = []
        
        // when
        store.observeState { old, new in
            oldStates.append(old)
            states.append(new)
        }
        
        // then
        XCTAssertEqual(oldStates, [nil], "Initial binding should trigger the notification with nil for old state")
        XCTAssertEqual(states, [State("A", 2)], "Initial binding should trigger the notification")
        
        store.update(states: State("A", 2), State("A", 3), State("B", 3), State("B", 2), State("B", 2))
        XCTAssertEqual(states, [State("A", 2), State("A", 3), State("B", 3), State("B", 2)], "update with same state should NOT trigger the notification")
        XCTAssertEqual(oldStates, [nil, State("A", 2), State("A", 3), State("B", 3)], "update with same state should NOT trigger the notification")
    }
    
    func test_ViewStore_State_Equatable() {
        enum TestModule: StoreModule {
            struct State: Equatable {
                let name: String
                let num: Int
                init(_ name: String, _ num: Int) {
                    self.name = name
                    self.num = num
                }
            }
        }
        typealias State = TestModule.State
        
        // given
        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("A", 2))
        let viewStore = store.asViewStore()
        
        var states: [State] = []
        var oldStates: [State?] = []
        
        // when
        viewStore.observeState { old, new in
            oldStates.append(old)
            states.append(new)
        }
        
        // then
        XCTAssertEqual(oldStates, [nil], "Initial binding should trigger the notification with nil for old state")
        XCTAssertEqual(states, [State("A", 2)], "Initial binding should trigger the notification")
        
        store.update(states: State("A", 2), State("A", 3), State("B", 3), State("B", 2), State("B", 2))
        XCTAssertEqual(states, [State("A", 2), State("A", 3), State("B", 3), State("B", 2)], "update with same state should NOT trigger the notification")
        XCTAssertEqual(oldStates, [nil, State("A", 2), State("A", 3), State("B", 3)], "update with same state should NOT trigger the notification")
    }

    func test_Store_State_NotEquatable_KeyPath_Equatable() {
        enum TestModule: StoreModule {
            struct State {
                var name: String
                init(_ name: String) { self.name = name }
            }
        }
        typealias State = TestModule.State
        
        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("A"))
        
        var names: [String] = []
        var newNames: [String] = []
        
        // when
        store.observeState(\.name) { names.append($0) }
        store.observeState(\.name) { _, new in newNames.append(new) }
        
        // then
        XCTAssertEqual(names, ["A"], "Initial binding should trigger the notification")
        XCTAssertEqual(newNames, ["A"], "Initial binding should trigger the notification")
        
        store.update(states: State("A"), State("B"), State("B"), State("A"))
        XCTAssertEqual(names, ["A", "B", "A"], "update with same (equatable) value should NOT trigger the notification")
        XCTAssertEqual(newNames, ["A", "B", "A"], "update with same (equatable) value should NOT trigger the notification")
    }
    
    func test_ViewStore_State_NotEquatable_OptionalKeyPath_Equatable() {
        enum TestModule: StoreModule {
            struct State {
                var name: String?
                init(_ name: String?) { self.name = name }
            }
        }
        typealias State = TestModule.State
        
        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("A"))
        let viewStore = store.asViewStore()
        
        var newNames: [String?] = []
        var names: [String?] = []
        
        // when
        viewStore.observeState(\.name) { names.append($0) }
        viewStore.observeState(\.name) { _, new in newNames.append(new) }
        
        // then
        XCTAssertEqual(names, ["A"], "Initial binding should trigger the notification")
        XCTAssertEqual(newNames, ["A"], "Initial binding should trigger the notification")
        
        store.update(states: State("A"), State("B"), State("B"), State(nil), State(nil), State("A"))
        XCTAssertEqual(names, ["A", "B", nil, "A"], "update with same (equatable) value should NOT trigger the notification")
        XCTAssertEqual(newNames, ["A", "B", nil, "A"], "update with same (equatable) value should NOT trigger the notification")
    }

    func test_Store_State_Equatable_Concurrent_Updates() {
        enum TestModule: StoreModule {
            struct State: Equatable {
                let name: String
                let num: Int
                init(_ name: String, _ num: Int) {
                    self.name = name
                    self.num = num
                }
            }
        }
        typealias State = TestModule.State
        let expectation = XCTestExpectation(description: #function)

        // given
        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("0", 0))

        var states: [State] = []
        var oldStates: [State?] = []
        let expectedResult = [State("0", 0), State("1", 1), State("2", 2), State("3", 3), State("4", 4)]

        // when
        store.observeState { old, new in
            oldStates.append(old)
            states.append(new)

            if states.count == expectedResult.count {
                expectation.fulfill()
            }
        }

        // then
        XCTAssertEqual(oldStates, [nil], "Initial binding should trigger the notification with nil for old state")
        XCTAssertEqual(states, [State("0", 0)], "Initial binding should trigger the notification")

        // when
        let concurrentQueue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
        for i in 0..<5 {
            concurrentQueue.async {
                store.update { $0 = State("\(i)", i) }
            }
        }

        wait(for: [expectation], timeout: 3.0)

        // then
        XCTAssert(states.allSatisfy(expectedResult.contains), "update with same state should NOT trigger the notification")
        XCTAssert(states.count == expectedResult.count, "states count should be equal expected result count")
        XCTAssertFalse(oldStates.contains(states.last), "update with same state should NOT trigger the notification")
        XCTAssert(oldStates.count == states.count, "old states count should be equal state count")
    }

    func test_ViewStore_State_Equatable_Concurrent_Updates() {
        enum TestModule: StoreModule {
            struct State: Equatable {
                let name: String
                let num: Int
                init(_ name: String, _ num: Int) {
                    self.name = name
                    self.num = num
                }
            }
        }
        typealias State = TestModule.State
        let expectation = XCTestExpectation(description: #function)

        // given
        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("0", 0))
        let viewStore = store.asViewStore()

        var states: [State] = []
        var oldStates: [State?] = []
        let expectedResult = [State("0", 0), State("1", 1), State("2", 2), State("3", 3), State("4", 4)]

        // when
        viewStore.observeState { old, new in
            oldStates.append(old)
            states.append(new)

            if states.count == expectedResult.count {
                expectation.fulfill()
            }
        }

        // then
        XCTAssertEqual(oldStates, [nil], "Initial binding should trigger the notification with nil for old state")
        XCTAssertEqual(states, [State("0", 0)], "Initial binding should trigger the notification")

        // when
        let concurrentQueue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
        for i in 0..<5 {
            concurrentQueue.async {
                store.update { $0 = State("\(i)", i) }
            }
        }

        wait(for: [expectation], timeout: 3.0)

        // then
        XCTAssert(states.allSatisfy(expectedResult.contains), "update with same state should NOT trigger the notification")
        XCTAssert(states.count == expectedResult.count, "states count should be equal expected result count")
        XCTAssertFalse(oldStates.contains(states.last), "update with same state should NOT trigger the notification")
        XCTAssert(oldStates.count == states.count, "old states count should be equal state count")
    }

    func test_Store_State_NotEquatable_KeyPath_Equatable_Concurrent_Updates() {
        enum TestModule: StoreModule {
            struct State {
                var name: String
                init(_ name: String) { self.name = name }
            }
        }
        typealias State = TestModule.State
        let newNamesExpectation = XCTestExpectation(description: "newNames Expectation")
        let namesExpectation = XCTestExpectation(description: "names Expectation")

        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("0"))

        var names: [String] = []
        var newNames: [String] = []
        let expectedResult = [State("0"), State("1"), State("2"), State("3"), State("4")]

        // when
        store.observeState(\.name) {
            names.append($0)

            if names.count == expectedResult.count {
                namesExpectation.fulfill()
            }
        }
        store.observeState(\.name) { _, new in
            newNames.append(new)

            if newNames.count == expectedResult.count {
                newNamesExpectation.fulfill()
            }
        }

        // then
        XCTAssertEqual(names, ["0"], "Initial binding should trigger the notification")
        XCTAssertEqual(newNames, ["0"], "Initial binding should trigger the notification")

        // when
        let concurrentQueue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
        for i in 0..<5 {
            concurrentQueue.async {
                store.update { $0 = State("\(i)") }
            }
        }

        wait(for: [namesExpectation, newNamesExpectation], timeout: 3.0)

        // then
        XCTAssert(names.allSatisfy { name in expectedResult.contains { $0.name == name } }, "update with same state should NOT trigger the notification")
        XCTAssert(names.count == expectedResult.count, "names count should be equal expected result count")
        XCTAssert(newNames.allSatisfy { newName in expectedResult.contains { $0.name == newName } }, "update with same state should NOT trigger the notification")
        XCTAssert(newNames.count == expectedResult.count, "newNames count should be equal expected result count")
    }

    func test_ViewStore_State_NotEquatable_OptionalKeyPath_Equatable_Concurrent_Updates() {
        enum TestModule: StoreModule {
            struct State {
                var name: String?
                init(_ name: String?) { self.name = name }
            }
        }
        typealias State = TestModule.State
        let newNamesExpectation = XCTestExpectation(description: "newNames Expectation")
        let namesExpectation = XCTestExpectation(description: "names Expectation")

        class TestStore: LassoStore<TestModule> { }
        let store = TestStore(with: State("0"))
        let viewStore = store.asViewStore()

        var newNames: [String?] = []
        var names: [String?] = []
        let expectedResult = [State("0"), nil, State("2"), State("3"), State("4")]

        // when
        viewStore.observeState(\.name) {
            names.append($0)

            if names.count == expectedResult.count {
                namesExpectation.fulfill()
            }
        }
        viewStore.observeState(\.name) { _, new in
            newNames.append(new)

            if newNames.count == expectedResult.count {
                newNamesExpectation.fulfill()
            }
        }

        // then
        XCTAssertEqual(names, ["0"], "Initial binding should trigger the notification")
        XCTAssertEqual(newNames, ["0"], "Initial binding should trigger the notification")

        // when
        let concurrentQueue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
        for i in 0..<5 {
            concurrentQueue.async {
                store.update { $0 = State(i == 1 ? nil : String(i)) }
            }
        }

        wait(for: [namesExpectation, newNamesExpectation], timeout: 3.0)

        // then
        XCTAssert(names.allSatisfy { name in  expectedResult.contains { $0?.name == name } }, "update with same state should NOT trigger the notification")
        XCTAssert(names.count == expectedResult.count, "names count should be equal expected result count")
        XCTAssert(newNames.allSatisfy { newName in expectedResult.contains { $0?.name == newName } }, "update with same state should NOT trigger the notification")
        XCTAssert(newNames.count == expectedResult.count, "newNames count should be equal expected result count")
    }

}

// MARK: - Helper to set multiple state values in succession

extension LassoStore {
    fileprivate func update(states: State...) {
        states.forEach { newState in
            self.update { $0 = newState }
        }
    }
}
