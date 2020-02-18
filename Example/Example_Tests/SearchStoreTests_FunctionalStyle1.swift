//
//===----------------------------------------------------------------------===//
//
//  SearchStoreTests_FunctionalStyle1.swift
//
//  Created by Trevor Beasty on 9/3/19.
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
@testable import Lasso_Example
import LassoTestUtilities

/// These test represent the preferred, more concise usage of the functional style.
/// This style should be used when State and Outputs are Equatable.

/// You must conform to LassoStoreTesting
class SearchStoreTestsFunctionalStyle1: XCTestCase, LassoStoreTesting {
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
            /// Specify the values of the initial state that matter for this test
            .given({ initialState in
                initialState.viewDidAppear = false
                initialState.searchText = nil
            })
            .when(actions(.viewWillAppear))
            /// Make assertions relevant to the prior when statement.
            .then(
                /// 'update' describes the difference between the Store's state before and after the 'when' event
                update { state in
                    state.phase = .searching
                    state.viewDidAppear = true
                },
                /// 'sideEffects' describe expectations unrelated to the Store
                sideEffects {
                    XCTAssertEqual(self.searchRequests.count, 1)
                    XCTAssertEqual(self.searchRequests[0].query, nil)
            })
        
        /// You may branch your test logic to reuse shared setup. Here, we want to test
        /// both the success and failure of the network request.
        
        // successful request
        loading
            .when(sideEffects {
                self.searchRequests[0].completion(.success(items))
            })
            /// 'singleUpdate' is more strict than 'update'. It requires that only 1 new State was produced.
            .then(singleUpdate { state in
                state.phase = .idle
                state.items = items
            })
            /// Because all statement execution is deferred, 'execute' must be called to trigger the test.
            .execute()
        
        // request failure
        loading
            .when(sideEffects {
                self.searchRequests[0].completion(.failure(NSError()))
            })
            /// You can also provide State instances when making State assertions
            .then(
                state(State(searchText: nil,
                            items: [],
                            phase: .error(message: "Something went wrong"),
                            viewDidAppear: true)))
            /// You may chain along as many 'when' and 'then' statements as you would like.
            .when(actions(.didAcknowledgeError))
            .then(singleUpdate { state in
                state.phase = .idle
            })
            /// Don't forget to call execute!!
            .execute()
    }
    
    func test_Selection() {
        let items = [Item(searchListTitle: "a")]
        
        test
            .given({
                $0.items = items
            })
            .when(actions(.didSelectItem(idx: 0)))
            /// You can also make assertions about Outputs from the Store.
            .then(outputs(.didSelectItem(items[0])))
            .execute()
    }
    
}
