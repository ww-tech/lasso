//
// ==----------------------------------------------------------------------== //
//
//  SearchStoreTests_FunctionalStyle2.swift
//
//  Created by Trevor Beasty on 10/3/19.
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
@testable import Lasso_Example
import LassoTestUtilities

/// These test represent the more general functional style.
/// This style should be used when State and Output are not NOT Equatable.

/// You must conform to LassoStoreTesting
class SearchStoreTestsFunctionalStyle2: XCTestCase, LassoStoreTesting {
    /// Be sure to explicitly declare the Store type to avoid compiler issues.
    typealias Store = SearchStore<Item>
    
    struct Item: SearchListRepresentable, Equatable {
        let searchListTitle: String
    }
    
    var searchRequests = [(query: String?, completion: (Result<[Item], Error>) -> Void)]()
    
    /// This is the factory for all your test cases. Because is accesses 'self', it must be lazy.
    lazy var test = TestFactory<SearchStore<Item>>(
        /// Provide some default initial state.
        initialState: State(searchText: nil,
                            items: [],
                            phase: .idle,
                            viewDidAppear: false),
        /// Set up the store. This is your chance to mock store dependencies, like network requests.
        setUpStore: { (store: SearchStore<Item>) -> Void in
            store.getSearchResults = { self.searchRequests.append(($0, $1)) }
    },
        /// Perform your typical teardown, resetting mocked values.
        tearDown: {
            self.searchRequests = []
    })
    
    func test_InitialFetch() {
        let items = [Item(searchListTitle: "a")]
        
        // loading state with pending request
        let loading = test
            .given({
                $0.viewDidAppear = false
                $0.searchText = nil
            })
            /// This is the most general form of 'when' statement you can make. You can dispatch Action's via the single argument.
            .when({ dispatchAction in
                dispatchAction(.viewWillAppear)
            })
            /// This is the most general form of 'then' assertion you can make.
            /// The single argument contains the emitted values. It has the members:
            ///   previousState: State
            ///   states: [State]
            ///   outputs: [Output]
            .then(assert { emitted in
                XCTAssertEqual(emitted.states.last, State(searchText: nil, items: [], phase: .searching, viewDidAppear: true))
                XCTAssertEqual(self.searchRequests.count, 1)
                XCTAssertEqual(self.searchRequests[0].query, nil)
            })
        
        /// You may branch your test logic to reuse shared setup. Here, we want to test
        /// both the success and failure of the network request.
        
        // successful request
        loading
            /// You can ignore 'dispatchAction' when performing just side effects.
            .when({ _ in
                self.searchRequests[0].completion(.success(items))
            })
            .then(assert { emitted in
                XCTAssertEqual(emitted.states.last, State(searchText: nil, items: items, phase: .idle, viewDidAppear: true))
            })
            .execute()
        
        // request failure
        loading
            .when({ _ in
                self.searchRequests[0].completion(.failure(NSError()))
            })
            .then(assert {
                XCTAssertEqual($0.states, [State(searchText: nil, items: [], phase: .error(message: "Something went wrong"), viewDidAppear: true)])
            })
            .when({ dispatchAction in dispatchAction(.didAcknowledgeError) })
            .then(assert { emitted in
                XCTAssertEqual(emitted.states, [State(searchText: nil, items: [], phase: .idle, viewDidAppear: true)])
            })
            .execute()
    }
    
    /// This is a repeat of the above test's success case shown in a different way.
    func test_InitialFetchSuccess_Condensed() {
        let items = [Item(searchListTitle: "a")]
        
        test
            .given({
                $0.viewDidAppear = false
                $0.searchText = nil
            })
            /// If you need to both dispatch Action's and invoke side effects, you need to open up a closure.
            .when({ dispatchAction in
                dispatchAction(.viewWillAppear)
                self.searchRequests[0].completion(.success(items))
            })
            /// You can make a large variety of assertions inside the 'assert' closure.
            .then(assert { (emitted) in
                let expectedStates = [
                    State(searchText: nil, items: [], phase: .searching, viewDidAppear: true),
                    State(searchText: nil, items: items, phase: .idle, viewDidAppear: true)
                ]
                XCTAssertEqual(emitted.states, expectedStates)
                
                XCTAssertTrue(emitted.outputs.isEmpty)
                
                XCTAssertEqual(self.searchRequests.count, 1)
                XCTAssertEqual(self.searchRequests[0].query, nil)
            })
            .execute()
    }
    
    func test_Selection() {
        let items = [Item(searchListTitle: "a")]
        
        test
            .given({
                $0.items = items
            })
            .when(actions(.didSelectItem(idx: 0)))
            .then(assert { emitted in
                XCTAssertEqual(emitted.outputs, [.didSelectItem(items[0])])
            })
            .execute()
    }
    
}
