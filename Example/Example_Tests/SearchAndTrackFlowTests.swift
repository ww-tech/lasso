//
// ==----------------------------------------------------------------------== //
//
//  SearchAndTrackFlowTests.swift
//
//  Created by Trevor Beasty on 7/19/19.
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

// 3 different testing styles are shown here. These styles use varying amounts of mocking and thus
// have varying testing "areas" - the greater the mocking, the smaller the testing area, and vice versa.

class SearchAndTrackFlowTestsWithDeepInjection: FlowTestCase {
    
    typealias ViewState = SearchViewModule<Food>.ViewState

    var flow: SearchAndTrackFlow!
    var searchRequests: [(searchText: String?, completion: (Result<[Food], Error>) -> Void)] = []
    
    override func setUp() {
        super.setUp()
        flow = SearchAndTrackFlow()
        flow.searchScreenFactory = screenFactory(configure: { searchStore in
            searchStore.getSearchResults = { searchText, completion in
                self.searchRequests.append((searchText, completion))
            }
        })
    }
    
    override func tearDown() {
        flow = nil
        super.tearDown()
    }
    
    func test_InitialFetch_Success() throws {
        
        let searchController: SearchViewController<Food> = try assertPresentation(
            on: rootController,
            when: { flow.start(with: presented(on: rootController)) },
            onViewDidLoad: { searchController in
                let initialSearchState = SearchViewModule<Food>.ViewState(isLoading: false, error: nil, items: [], searchText: nil)
                XCTAssertEqual(searchController.store.state, initialSearchState)
                XCTAssertTrue(searchRequests.isEmpty)
        },
            onViewWillAppear: { searchController in
                let loadingState = SearchViewModule<Food>.ViewState(isLoading: true, error: nil, items: [], searchText: nil)
                XCTAssertEqual(searchController.store.state, loadingState)
                XCTAssertEqual(self.searchRequests.count, 1)
                XCTAssertEqual(self.searchRequests[0].searchText, nil)
        })

        // when - request completion - success
        let food = Food(name: "", points: 0, description: "")
        searchRequests[0].completion(.success([food]))
        
        // then
        let searchResultState = SearchViewModule<Food>.ViewState(isLoading: false, error: nil, items: [food], searchText: nil)
        XCTAssertEqual(searchController.store.state, searchResultState)
    }
    
    func test_InitialFetch_Failure() throws {
        
        let searchController: SearchViewController<Food> = try assertPresentation(
            on: rootController,
            when: { flow.start(with: presented(on: rootController)) },
            onViewDidLoad: { _ in
                XCTAssertTrue(self.searchRequests.isEmpty)
        },
            onViewWillAppear: { _ in
                XCTAssertEqual(self.searchRequests.count, 1)
        })

        // when - request completion - failure
        let error = NSError(domain: "", code: 0, userInfo: nil)
        searchRequests[0].completion(.failure(error))
        
        // then
        let searchErrorState = SearchViewModule<Food>.ViewState(isLoading: false, error: "Something went wrong", items: [], searchText: nil)
        XCTAssertEqual(searchController.store.state, searchErrorState)
    }
    
    func test_Search_Success() throws {
        // start flow
        let searchController: SearchViewController<Food> = try assertPresentation(on: rootController, when: { flow.start(with: presented(on: rootController)) })
        
        // when - search text event
        searchRequests = []
        searchController.store.dispatchAction(.didUpdateSearchText("a"))
        
        // then
        let searchPendingState = ViewState(isLoading: true, error: nil, items: [], searchText: "a")
        XCTAssertEqual(searchController.store.state, searchPendingState)
        XCTAssertEqual(searchRequests.count, 1)
        XCTAssertEqual(searchRequests[0].searchText, "a")
        
        // when - request success
        let food = Food(name: "", points: 0, description: "")
        searchRequests[0].completion(.success([food]))
        
        // then
        let searchResultState = SearchViewModule<Food>.ViewState(isLoading: false, error: nil, items: [food], searchText: "a")
        XCTAssertEqual(searchController.store.state, searchResultState)
    }
    
    func test_Selection_ShowsDetail_Track_ShowsSearch() throws {
        // start flow
        let searchController: SearchViewController<Food> = try assertPresentation(
            on: rootController,
            when: { flow.start(with: presented(on: rootController)) }
        )
        
        // search request success
        let food = Food(name: "a", points: 0, description: "b")
        self.searchRequests[0].completion(.success([food]))
        
        let detailController: TextViewController = try assertPresentation(
            on: searchController,
            when: {
                // search screen - food selection
                searchController.store.dispatchAction(.didSelectItem(idx: 0))
        },
            onViewDidLoad: { detailController in
                let detailState = TextViewController.ViewState(title: "a", description: "0 Points\n\nb", buttons: ["Track"])
                XCTAssertEqual(detailController.store.state, detailState)
        })
        
        // detail screen - track food
        try assertDismissal(
            from: detailController,
            to: searchController,
            when: { detailController.store.dispatchAction(.didTapButton(0)) }
        )
    }

}

class SearchAndTrackFlowTestsWithShallowInjection: FlowTestCase {
    
    typealias ViewState = SearchViewModule<Food>.ViewState

    var flow: SearchAndTrackFlow!
    var mockSearchScreen: MockScreen<SearchScreenModule<Food>>!
    var mockFoodDetailScreen: MockScreen<TextScreenModule>!
    
    override func setUp() {
        super.setUp()
        flow = SearchAndTrackFlow()
        mockSearchScreen = MockScreen<SearchScreenModule<Food>>()
        mockFoodDetailScreen = MockScreen<TextScreenModule>()
        
        flow.searchScreenFactory = mockScreenFactory(mockScreen: mockSearchScreen)
        flow.foodDetailScreenFactory = mockScreenFactory(mockScreen: mockFoodDetailScreen)
    }
    
    override func tearDown() {
        flow = nil
        mockSearchScreen = nil
        mockFoodDetailScreen = nil
        super.tearDown()
    }
    
    func test_Selection_ShowsDetail_Track_ShowsSearch() throws {
        let searchController: UIViewController = try assertPresentation(
            on: rootController,
            when: { flow.start(with: presented(on: rootController)) }
        )
        XCTAssertEqual(searchController, mockSearchScreen.mockController)
        
        let food = Food(name: "a", points: 0, description: "b")
        let foodDetailController: UIViewController = try assertPresentation(
            on: searchController,
            when: { mockSearchScreen.mockStore?.dispatchMockOutput(.didSelectItem(food)) }
        )
        XCTAssertEqual(foodDetailController, mockFoodDetailScreen.mockController)
        let detailState = TextViewController.ViewState(title: "a", description: "0 Points\n\nb", buttons: ["Track"])
        XCTAssertEqual(mockFoodDetailScreen.mockStore?.state, detailState)
        
        try assertDismissal(
            from: foodDetailController,
            to: searchController,
            when: { mockFoodDetailScreen.mockStore?.dispatchMockOutput(.didTapButton(0)) }
        )
    }

}

class SearchAndTrackFlowTestsWithMockController: FlowTestCase {
    
    typealias SearchState = SearchScreenModule<Food>.State

    var flow: SearchAndTrackFlow!
    var searchRequests: [(searchText: String?, completion: (Result<[Food], Error>) -> Void)] = []
    
    override func setUp() {
        super.setUp()
        flow = SearchAndTrackFlow()

        flow.searchScreenFactory = mockControllerScreenFactory(configure: { searchStore in
            searchStore.getSearchResults = { searchText, completion in
                self.searchRequests.append((searchText, completion))
            }
        })
    }
    
    override func tearDown() {
        flow = nil
        super.tearDown()
    }
    
    private func start() throws -> SearchScreenModule<Food>.MockController {
        return try assertPresentation(
            on: rootController,
            when: { flow.start(with: presented(on: rootController)) }
        )
    }
    
    func test_InitialFetch_Success() throws {
        let searchController = try start()
        
        let initialSearchState = SearchState(searchText: nil, items: [], phase: .idle, viewDidAppear: false)
        XCTAssertEqual(searchController.store.state, initialSearchState)
        XCTAssertTrue(searchRequests.isEmpty)
        
        // viewWillAppear
        searchController.store.dispatchAction(.viewWillAppear)
        
        let loadingState = SearchState(searchText: nil, items: [], phase: .searching, viewDidAppear: true)
        XCTAssertEqual(searchController.store.state, loadingState)
        XCTAssertEqual(self.searchRequests.count, 1)
        XCTAssertEqual(self.searchRequests[0].searchText, nil)

        // request completion
        let food = Food(name: "", points: 0, description: "")
        searchRequests[0].completion(.success([food]))
        
        let searchResultState = SearchState(searchText: nil, items: [food], phase: .idle, viewDidAppear: true)
        XCTAssertEqual(searchController.store.state, searchResultState)
    }
    
    func test_InitialFetch_Failure() throws {
        let searchController = try start()

        // request completion
        let error = NSError(domain: "", code: 0, userInfo: nil)
        searchController.store.dispatchAction(.viewWillAppear)
        searchRequests[0].completion(.failure(error))
        
        let searchErrorState = SearchState(searchText: nil, items: [], phase: .error(message: "Something went wrong"), viewDidAppear: true)
        XCTAssertEqual(searchController.store.state, searchErrorState)
    }
    
    func test_Search_Success() throws {
        // start flow
        let searchController = try start()

        // search text event
        searchController.store.dispatchAction(.didUpdateSearchText("a"))

        let searchPendingState = SearchState(searchText: "a", items: [], phase: .searching, viewDidAppear: false)
        XCTAssertEqual(searchController.store.state, searchPendingState)
        XCTAssertEqual(searchRequests.count, 1)
        XCTAssertEqual(searchRequests[0].searchText, "a")

        // request success
        let food = Food(name: "", points: 0, description: "")
        searchRequests[0].completion(.success([food]))

        let searchResultState = SearchState(searchText: "a", items: [food], phase: .idle, viewDidAppear: false)
        XCTAssertEqual(searchController.store.state, searchResultState)
    }
    
    func test_Selection_ShowsDetail_Track_ShowsSearch() throws {
        // start flow
        let searchController = try start()
        
        // search request success
        let food = Food(name: "a", points: 0, description: "b")
        searchController.store.dispatchAction(.viewWillAppear)
        self.searchRequests[0].completion(.success([food]))
        
        let detailController: TextViewController = try assertPresentation(
            on: searchController,
            when: { searchController.store.dispatchAction(.didSelectItem(idx: 0)) }
        )
        
        let detailState = TextViewController.ViewState(title: "a", description: "0 Points\n\nb", buttons: ["Track"])
        XCTAssertEqual(detailController.store.state, detailState)
        
        // detail screen - track food
        try assertDismissal(
            from: detailController,
            to: searchController,
            when: { detailController.store.dispatchAction(.didTapButton(0)) }
        )
    }

}
