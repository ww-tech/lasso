//
//===----------------------------------------------------------------------===//
//
//  LassoStoreTestCase.swift
//
//  Created by Steven Grosmark on 10/2/19.
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

/// Wrapper used to test a Store.
///
/// Works in conjunction with the `LassoStoreTestCase` protocol that:
/// - requires a `testableStore` var
/// - exposes access to the underlying `store`, a `markerState`, and `outputs`, `states` arrays
///   - the `store` is the store under test
///   - `markerState` starts out equal to the store's initial state,
///      and is used as a marker for testing a `store`'s state after some action(s) occurs
///   - `states` is an array of all `State` values emitted by the `store`
///   - `outputs` is an array of all `Output` values dispatched by the `store`
///
/// Usage:
/// ```
/// // Declare your test case, and adopt the LassoStoreTestCase protocol:
/// class MyStoreTests: XCTestCase, LassoStoreTestCase {
///
///     // declare and create a TestableStore instance:
///     let testableStore = TestableStore<MyStoreModule.Store>()
///
///     // initialize the `store` in your `setUp()` override:
///     override func setUp() {
///         super.setUp()
///         store = MyStoreModule.createScreen().store
///
///         // optionally dispatch any actions, and capture the state as an initial starting point for all tests
///         // e.g.:
///         //  store.dispatchAction(.viewDidAppear)
///         //  syncState() // sets `markerState` = `store.state`, and `states` = `[store.state]`
///     }
///
///     // write some tests
///     func test_MyStore() {
///         // access the store directly:
///         store.dispatchAction(.didTapSomething)
///
///         // assert the current state against the `markerState`:
///         XCTAssertStateEquals(updatedMarker: { state in
///             state.someProperty = "something"
///         })
///
///         // `markerState` now reflects the applied updates
///         XCTAssertEqual(store.state, markerState)
///         // or:
///         XCTAssertStateEquals(markerState)
///
///         // test outputs:
///         XCTAssertOutputs([.didSomething])
///         XCTAssertLastOutput(.didSomething)
///     }
/// }
/// ```
public class TestableStore<Store: AbstractStore> {
    
    public init() { }
    
    public var store: Store! {
        didSet {
            markerState = store.state
            outputs = []
            states = []
            store.observeOutput { [weak self] output in self?.outputs.append(output) }
            store.observeState { [weak self] _, state in self?.states.append(state) }
        }
    }
    
    var markerState: Store.State!
    var outputs = [Store.Output]()
    var states = [Store.State]()
}

public protocol LassoStoreTestCase: XCTestCase {
    associatedtype Store: AbstractStore
    
    typealias State = Store.State
    typealias Action = Store.Action
    typealias Output = Store.Output
    
    var testableStore: TestableStore<Store> { get }
}

extension LassoStoreTestCase {
    
    /// The `store` under test.
    public var store: Store! {
        get { return testableStore.store }
        set { testableStore.store = newValue }
    }
    
    /// An instance of `State` used to track alongside the `store`'s `state`.
    ///
    /// `markerState` will start out equal to the `store.state`, and is used as a starting point
    /// for asserting expectations against `store.state`
    /// The `markerState` is modifiable via the `updatedMarker` func, typically used when
    /// making assertions.  E.g.:
    /// ```
    /// store.dispatchAction(.didSomething)
    /// XCTAssertStateEquals(updatedMarker { state in
    ///     state.name = "something"
    /// })
    /// ```
    public var markerState: State! { return testableStore.markerState }
    
    /// A collection `State` values, as emitted by the `store`
    public var states: [State] { return testableStore.states }
    
    /// Update the `markerState`
    /// - Parameter update: closure that updates the `markerState`
    /// - Returns: the updated `markerState`
    @discardableResult
    public func updatedMarker(_ update: (inout State) -> Void) -> State {
        update(&testableStore.markerState)
        return testableStore.markerState
    }
    
    /// Resets the `markerState` and `states` properties to match the current `store.state`,
    /// as if the store was just created.
    ///
    /// Sets the `markerState` to the current `store.state`.
    /// Sets the `states` array to `[store.state]`
    public func syncState() {
        testableStore.markerState = store.state
        testableStore.states = [store.state]
    }
    
    /// A collection of `Output` values as emitted by the `store`
    ///
    /// Use `XCTAssertOutputs` and/or `XCTAssertLastOutput` to make assertions.
    public var outputs: [Output] { return testableStore.outputs }
    
    /// Resets the `outputs` to `[]`.
    public func resetOutputs() {
        testableStore.outputs = []
    }
    
}

// MARK: XCTestCase + nicer assertions

extension LassoStoreTestCase where Output: Equatable {
    
    public func XCTAssertOutputs(_ expected: [Output], file: StaticString = #file, line: UInt = #line) {
        LassoAssertEqual(outputs, expected, file: file, line: line)
    }
    
    public func XCTAssertLastOutput(_ expected: Output, file: StaticString = #file, line: UInt = #line) {
        LassoAssertEqual(outputs.last, expected, file: file, line: line)
    }
    
}

extension LassoStoreTestCase where State: Equatable {
    
    /// Asserts `store.state` equals an expected State value.
    ///
    /// The most common use case is to assert that `store.state` is equal
    /// to the `markerState` with some property updates:
    /// ```
    /// XCTAssertStateEquals(updatedMarker { state in
    ///     state.name = "something"
    /// })
    /// ```
    /// `markerState` is reset to `store.state` after the assertion is made.
    ///
    /// - Parameter expected: the expected State value
    public func XCTAssertStateEquals(_ expected: State, file: StaticString = #file, line: UInt = #line) {
        LassoAssertEqual(store.state, expected, file: file, line: line)
        testableStore.markerState = store.state
    }
    
    public func XCTAssertStates(_ expected: [State], file: StaticString = #file, line: UInt = #line) {
        LassoAssertEqual(states, expected, file: file, line: line)
    }
    
}

extension XCTestCase {

    public func LassoAssertEqual<A: Equatable>(_ realized: A, _ expected: A, file: StaticString = #file, line: UInt = #line) {
        if realized != expected {
            XCTFail("realized differs from expected" + messageDescribingDiffs(realized, expected), file: file, line: line)
        }
    }
    
    public func LassoAssertEqual<A: Equatable>(_ realized: A?, _ expected: A?, file: StaticString = #file, line: UInt = #line) {
        if realized != expected {
            if realized == nil || expected == nil {
                return XCTAssertEqual(realized, expected, file: file, line: line)
            }
            XCTFail("realized differs from expected" + messageDescribingDiffs(realized, expected), file: file, line: line)
        }
    }

    public func LassoAssertEqual<A: Equatable>(_ realized: [A], _ expected: [A], file: StaticString = #file, line: UInt = #line) {
        if realized != expected {
            if realized.isEmpty || expected.isEmpty {
                return XCTAssertEqual(realized, expected, file: file, line: line)
            }
            XCTFail("realized differs from expected" + messageDescribingDiffs(realized, expected), file: file, line: line)
        }
    }

}
