//
// ==----------------------------------------------------------------------== //
//
//  RandomItems.swift
//
//  Created by Steven Grosmark on 5/21/19.
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

import UIKit
import Lasso

/// Displays a searchable table view of items.
/// Selecting an item shows details for the item
///
/// This flow emits No output.
/// This flow requires that it is placed in a  navigation controller.
class RandomItemsFlow: Flow<NoOutputNavigationFlow> {
    
    /// Creates the initial view controller for the RandomItemsFlow -
    /// the searchable table view of items.
    override func createInitialController() -> UIViewController {
        return RandomItems
            .createScreen()
            .observeOutput(handleOutput)
            .controller
    }
    
    /// Handles the Output from the RandomItems screen - the table view
    private func handleOutput(_ output: RandomItems.Output) {
        switch output {
            
        case .didSelectItem(let item):
            let state = TextScreenModule.State(title: item.name,
                                               description: item.description)
            TextScreenModule
                .createScreen(with: state)
                .place(with: nextPushedInFlow)
        }
    }
}

enum RandomItems: ScreenModule {
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: RandomItemsStore) -> Screen {
        let controller = RandomItemsViewController(store: store.asViewStore())
        return Screen(store, controller)
    }

    enum Action: Equatable {
        case didSelectItem(Item)
        case didUpdateSearchQuery(String?)
    }
    
    enum Output: Equatable {
        case didSelectItem(Item)
    }
    
    struct State: Equatable {
        let items: [Item]
        var query: String?
        var foundItems: [Item]?
    }
    
    struct Item: Equatable {
        let name: String
        let description: String
    }
    
}

class RandomItemsStore: LassoStore<RandomItems> {
    
    override func handleAction(_ action: RandomItems.Action) {
        switch action {
            
        case .didSelectItem(let item):
            dispatchOutput(.didSelectItem(item))
            
        case .didUpdateSearchQuery(let query):
            if let query = query, !query.isEmpty {
                update { state in
                    state.query = query
                    state.foundItems = state.items.filter { $0.name.range(of: query, options: .caseInsensitive) != nil }
                }
            }
            else {
                update { state in
                    state.query = nil
                    state.foundItems = nil
                }
            }
        }
    }
}

extension RandomItems.State {
    init() {
        var items = [RandomItems.Item]()
        for _ in 0..<30 {
            let item = RandomItems.Item(name: String.randomWord().capitalized,
                                        description: .loremIpsum(sentences: Int.random(in: 1...4)))
            items.append(item)
        }
        self.items = items
    }
}

class RandomItemsViewController: UIViewController, LassoView {
    
    let store: RandomItems.ViewStore
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    init(store: RandomItems.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        tableView.register(type: UITableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        // Allows search controller to get pushed along with everything else, and maintain its state:
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(tableView)
        
        tableView.layout.fill(.safeArea)
        
        // State observations:
        // (note that `items` is a `let` property - meaning it won't change - so no need to observe it)
        store.observeState(\.query) { [weak self] query in
            self?.searchController.searchBar.text = query
        }
        store.observeState(\.foundItems) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
}

extension RandomItemsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        store.dispatchAction(.didUpdateSearchQuery(searchController.searchBar.text))
    }
    
}

extension RandomItemsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let items = store.state.foundItems ?? store.state.items
        let item = items[indexPath.row]
        
        store.dispatchAction(.didSelectItem(item))
    }
}

extension RandomItemsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.state.foundItems?.count ?? store.state.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: UITableViewCell.self, indexPath: indexPath)
        let items = store.state.foundItems ?? store.state.items
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
}
