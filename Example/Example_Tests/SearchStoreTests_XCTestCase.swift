//
//===----------------------------------------------------------------------===//
//
//  SearchStoreTests_XCTestCase.swift
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
//===----------------------------------------------------------------------===//
//

import XCTest
@testable import Lasso_Example

///
/// Example of Store unit testing w/no support utilities.
///

class SearchStoreAltTests: XCTestCase {
    
    struct Item: SearchListRepresentable, Equatable {
        let searchListTitle: String
    }
    
    typealias Module = SearchScreenModule<Item>
    typealias State = Module.State
    
    var searchRequests = [(query: String?, completion: (Result<[Item], Error>) -> Void)]()

    var store: SearchStore<Item>!
    
    enum MockError: Error {
        case failed
    }
    
    override func setUp() {
        super.setUp()
        
        store = SearchStore<Item>(with: State(searchText: nil, items: [], phase: .idle, viewDidAppear: false))
        store.getSearchResults = { self.searchRequests.append(($0, $1)) }
        searchRequests = []
        store.dispatchAction(.viewWillAppear)
    }
    
    func test_InitialFetchOnViewWillAppear() {
        // TEST: loading state with pending request
        XCTAssertEqual(store.state, State(searchText: nil, items: [], phase: .searching, viewDidAppear: true))
        XCTAssertEqual(self.searchRequests.count, 1)
        XCTAssertEqual(self.searchRequests[0].query, nil)
    }
    
    func test_RequestSuccess() {
        
        // when
        let items = [Item(searchListTitle: "a")]
        searchRequests[0].completion(.success(items))
        
        // then
        XCTAssertEqual(store.state, State(searchText: nil, items: items, phase: .idle, viewDidAppear: true))
    }
    
    func test_RequestFailure() {
        
        // when
        searchRequests[0].completion(.failure(MockError.failed))
        
        // then
        XCTAssertEqual(store.state, State(searchText: nil, items: [], phase: .error(message: "Something went wrong"), viewDidAppear: true))
        
        // when
        store.dispatchAction(.didAcknowledgeError)
        
        // then
        XCTAssertEqual(store.state, State(searchText: nil, items: [], phase: .idle, viewDidAppear: true))
    }
    
    func test_Selection() {
        
        // given
        let items = [Item(searchListTitle: "a")]
        searchRequests[0].completion(.success(items))
        var outputs = [Module.Output]()
        store.observeOutput { outputs.append($0) }
        
        // when
        store.dispatchAction(.didSelectItem(idx: 0))
        
        // then
        XCTAssertEqual(outputs, [.didSelectItem(items[0])])
    }

}
