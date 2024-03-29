//
// ==----------------------------------------------------------------------== //
//
//  ValueBinderTests.swift
//
//  Created by Steven Grosmark on 6/10/19.
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

class ValueBinderTests: XCTestCase {
    
    func test_ValueBinder_IntValue_Equatable() {
        // given
        let observable = ValueBinder(1)
        var changes: [Int] = []
        
        // when
        observable.bind { _, newValue in changes.append(newValue) }
        
        // then
        XCTAssertEqual(changes, [1], "Initial binding should trigger the notification")
        
        observable.set(values: 1, 2, 2, 1)
        XCTAssertEqual(changes, [1, 2, 1], "update with same (equatable) value should NOT trigger the notification")
    }
    
    func test_ValueBinder_Struct_NotEquatable() {
        struct Test {
            let name: String
            init(_ name: String) { self.name = name }
        }
        
        // given
        let observable = ValueBinder(Test("A"))
        var changes: [String] = []
        
        // when
        observable.bind { _, newValue in changes.append(newValue.name) }
        
        // then
        XCTAssertEqual(changes, ["A"], "Initial binding should trigger the notification")
        
        observable.set(values: Test("A"), Test("B"), Test("B"))
        XCTAssertEqual(changes, ["A", "A", "B", "B"], "update with same (not-equatable) value should trigger the notification")
    }
    
    func test_ValueBinder_KeyPath_NotEquatable() {
        struct Test {
            // 'name' is the keyPath to be tested. It is not equatable, as mandated.
            let name: Name

            init(_ name: String) {
                self.name = Name(value: name)
            }
            
            struct Name {
                let value: String
            }
            
        }
        
        // given
        let observable = ValueBinder(Test("A"))
        var names: [Test.Name] = []
        
        var nameValues: [String] {
            return names.map { $0.value }
        }
        
        // when
        observable.bind(\.name) { _, newName in names.append(newName) }
        
        // then
        XCTAssertEqual(nameValues, ["A"], "Initial binding should trigger the notification")
        
        observable.set(values: Test("A"), Test("B"), Test("B"))
        XCTAssertEqual(nameValues, ["A", "A", "B", "B"], "update with same (not-equatable) value should trigger the notification")
    }
    
    func test_ValueBinder_OptionalKeyPath_NotEquatable() {
        struct Test {
            // 'name' is the keyPath to be tested. It is not equatable, as mandated.
            let name: Name?
            
            init(_ name: String?) {
                if let name = name {
                    self.name = Name(value: name)
                }
                else {
                    self.name = nil
                }
            }
            
            struct Name {
                let value: String
            }
            
        }
        
        // given
        let observable = ValueBinder(Test("A"))
        var names: [Test.Name?] = []
        
        var nameValues: [String?] {
            return names.map { $0.map { $0.value } }
        }
        
        // when
        observable.bind(\.name) { _, newName in names.append(newName) }
        
        // then
        XCTAssertEqual(nameValues, ["A"], "Initial binding should trigger the notification")
        
        observable.set(values: Test("A"), Test(nil), Test(nil), Test("B"))
        XCTAssertEqual(nameValues, ["A", "A", nil, nil, "B"], "update with same (not-equatable) value should trigger the notification")
    }
    
    func test_ValueBinder_Struct_NotEquatable_OptionalKeyPath_Equatable() {
        struct Test {
            let name: String?
            init(_ name: String?) { self.name = name }
        }
        
        // given
        let observable = ValueBinder(Test("A"))
        var names: [String?] = []
        
        // when
        observable.bind(\.name) { _, newName in names.append(newName) }
        
        // then
        XCTAssertEqual(names, ["A"], "Initial binding should trigger the notification")
        
        observable.set(values: Test("A"), Test("B"), Test("B"), Test("A"))
        XCTAssertEqual(names, ["A", "B", "A"], "update with same (equatable) value should NOT trigger the notification")
    }
    
    func test_ValueBinder_Struct_Equatable() {
        struct Test: Equatable {
            let name: String
            init(_ name: String) { self.name = name }
        }
        
        // given
        let observable = ValueBinder(Test("A"))
        var changes: [String] = []
        
        // when
        observable.bind { _, newValue in changes.append(newValue.name) }
        
        // then
        XCTAssertEqual(changes, ["A"], "Initial binding should trigger the notification")
        
        observable.set(values: Test("A"), Test("B"), Test("B"), Test("A"))
        XCTAssertEqual(changes, ["A", "B", "A"], "update with same (equatable) value should NOT trigger the notification")
    }
    
    func test_ValueBinder_KeyPath_Equatable() {
        struct Test: Equatable {
            let name: String
            let num: Int
            init(_ name: String, _ num: Int) {
                self.name = name
                self.num = num
            }
        }
        
        // given
        let observable = ValueBinder(Test("A", 2))
        var changes: [String] = []
        
        // when
        observable.bind(\.name) { _, newName in changes.append(newName) }
        
        // then
        XCTAssertEqual(changes, ["A"], "Initial binding should trigger the notification")
        
        observable.set(values: Test("A", 2), Test("A", 3), Test("B", 3), Test("B", 2), Test("A", 2))
        XCTAssertEqual(changes, ["A", "B", "A"], "update with same (equatable) value should NOT trigger the notification")
    }
    
    func test_ValueBinder_OptionalKeyPath_Equatable() {
        struct Test: Equatable {
            let name: String?
            let num: Int
            init(_ name: String?, _ num: Int) {
                self.name = name
                self.num = num
            }
        }
        
        // given
        let observable = ValueBinder(Test("A", 2))
        var changes: [String?] = []
        
        // when
        observable.bind(\.name) { _, newName in changes.append(newName) }
        
        // then
        XCTAssertEqual(changes, ["A"], "Initial binding should trigger the notification")
        
        observable.set(values: Test("A", 2), Test(nil, 3), Test(nil, 2), Test("B", 2), Test("B", 2))
        XCTAssertEqual(changes, ["A", nil, "B"], "update with same (equatable) value should NOT trigger the notification")
    }

    func test_ValueBinder_Struct_NotEquatable_Concurrent_Subscribers() {
        struct Test {
            let name: String
            init(_ name: String) { self.name = name }
        }

        // given
        let observable = ValueBinder(Test("1"))
        var changes: [String] = []
        let expectedCount = 33
        let expectedResult = ["1", "1", "1", "1", "1", "1", "2", "2", "2", "3", "3", "3", "4", "4", "4", "5", "5", "5", "6", "6", "6", "7", "7", "7", "8", "8", "8", "9", "9", "9", "10", "10", "10"]

        // when
        let expectation = XCTestExpectation(description: #function)
        let subscriptions = 3

        DispatchQueue.concurrentPerform(iterations: subscriptions) { _ in
            observable.bind { _, newValue in
                changes.append(newValue.name)
                if changes.count == subscriptions {
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 1)

        // then
        XCTAssertEqual(changes, ["1", "1", "1"], "Initial binding should trigger the notification")

        // when
        (1...10).forEach { observable.set(Test("\($0)")) }

        // then
        XCTAssertEqual(changes.count, expectedCount, "changes count should equeal expectedCount")
        XCTAssertEqual(changes, expectedResult, "changes should be equeal expectedResult")
    }

}

// MARK: - Helper to set multiple values in succession

extension ValueBinder {
    fileprivate func set(values: Value...) {
        values.forEach(set)
    }
}
