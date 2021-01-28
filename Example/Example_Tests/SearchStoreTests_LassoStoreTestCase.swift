//
// ==----------------------------------------------------------------------== //
//
//  SearchStoreTests_LassoStoreTestCase.swift
//
//  Created by Steven Grosmark on 9/19/19.
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
import LassoTestUtilities
@testable import Lasso_Example

///
/// Example of Store unit testing using `LassoStoreTestCase` and `TestableStore`.
///

struct Item: SearchListRepresentable, Equatable {
    let searchListTitle: String
}

enum MockError: Error {
    case failed
}

// MARK: - Lifecycle tests

/// Test case that tests the normal lifecycle:
///     viewDidAppear,
///     viewDidAppear + successful request,
///     viewDidAppear + failed request
class SearchStoreLifecycleTests: XCTestCase, LassoStoreTestCase {

    let testableStore = TestableStore<SearchStore<Item>>()
    
    var searchRequests = [(query: String?, completion: (Result<[Item], Error>) -> Void)]()
    
    override func setUp() {
        super.setUp()
        
        // create the store
        store = SearchStore<Item>(with: State(searchText: nil, items: [], phase: .idle, viewDidAppear: false))
        
        // setup initial state - a.k.a. the "given" for each test
        store.getSearchResults = { self.searchRequests.append(($0, $1)) }
        searchRequests = []
        store.dispatchAction(.viewWillAppear)
        syncState()
    }
    
    func test_InitialFetchOnViewWillAppear() {
        // validate initial state
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .searching
            state.viewDidAppear = true
        })
        XCTAssertEqual(searchRequests.count, 1)
        XCTAssertEqual(searchRequests[0].query, nil)
    }
    
    func test_RequestSuccess() {
        // when - search service completes with success
        let items = [Item(searchListTitle: "a")]
        searchRequests[0].completion(.success(items))
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .idle
            state.items = items
        })
    }
    
    func test_RequestFailure() {
        // when - search service completes with failure
        searchRequests[0].completion(.failure(MockError.failed))
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .error(message: "Something went wrong")
        })
        
        // when - user acknowledges error
        store.dispatchAction(.didAcknowledgeError)
        
        // then
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .idle
        })
    }
        
}

// MARK: - Selection tests

/// Test case that tests selecting an item.
///
/// Create a unique test case subclass when you want to run
/// a number of tests that all have the same "given" state.
class SearchStoreSelectionTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<SearchStore<Item>>()
    let item = Item(searchListTitle: "a")
    
    override func setUp() {
        super.setUp()
        
        // create the store with an initial state of being after a successful search
        // i.e., given: store has completed a successful search
        store = SearchStore<Item>(with: State(searchText: "a", items: [item], phase: .idle, viewDidAppear: true))
    }
    
    func test_Selection_Valid() {
        // when
        store.dispatchAction(.didSelectItem(idx: 0))
        
        // then
        XCTAssertLastOutput(.didSelectItem(item))   // assert on the last dispatched output, or
        XCTAssertOutputs([.didSelectItem(item)])    // assert on the array of outputs
    }
    
    func test_Selection_InvalidIndex() {
        // when
        store.dispatchAction(.didSelectItem(idx: -1))
        store.dispatchAction(.didSelectItem(idx: 999))
        
        // then
        XCTAssertOutputs([])
    }

}
