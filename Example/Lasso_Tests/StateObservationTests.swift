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

}

// MARK: - Helper to set multiple state values in succession

extension LassoStore {
    fileprivate func update(states: State...) {
        states.forEach { newState in
            self.update { $0.state = newState }
        }
    }
}
