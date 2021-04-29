//
// ==----------------------------------------------------------------------== //
//
//  SearchModule.swift
//
//  Created by Trevor Beasty on 5/2/19.
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

protocol SearchListRepresentable {
    var searchListTitle: String { get }
}

enum SearchScreenModule<Item: SearchListRepresentable & Equatable>: ScreenModule {
    
    struct State: Equatable {
        var searchText: String?
        var items: [Item]
        var phase: Phase
        var viewDidAppear: Bool
        
        enum Phase: Equatable {
            case idle
            case searching
            case error(message: String)
        }
        
    }
    
    enum Action: Equatable {
        case didUpdateSearchText(String?)
        case didPressClear
        case didSelectItem(idx: Int)
        case viewWillAppear
        case didAcknowledgeError
    }
    
    enum Output: Equatable {
        case didSelectItem(Item)
    }
    
    struct Item: Equatable {
        let id: String
        let name: String
        let points: Int
    }
    
    static var defaultInitialState: State {
        return State(searchText: nil, items: [], phase: .idle, viewDidAppear: false)
    }
    
    static func createScreen(with store: SearchStore<Item>) -> Screen {
        let viewStore = store.asViewStore(stateMap: { $0.asViewState })
        let controller = SearchViewController(store: viewStore)
        return Screen(store, controller)
    }
    
}

enum SearchViewModule<Item: SearchListRepresentable & Equatable>: ViewModule {
    
    struct ViewState: Equatable {
        var isLoading: Bool
        var error: String?
        var items: [Item]
        var searchText: String?
    }
    
    typealias ViewAction = SearchScreenModule<Item>.Action
    
}

class SearchStore<Item: SearchListRepresentable & Equatable>: LassoStore<SearchScreenModule<Item>> {
    
    var getSearchResults: (String?, @escaping (Result<[Item], Error>) -> Void) -> Void = { _, _ in }
    
    override func handleAction(_ action: Action) {
        switch action {
        case .didPressClear:
            search(nil)
            
        case .didSelectItem(let idx):
            guard idx >= 0, idx < state.items.count else { return }
            dispatchOutput(.didSelectItem(state.items[idx]))
            
        case .didUpdateSearchText(let searchText):
            search(searchText)
            
        case .viewWillAppear:
            handleViewWillAppear()
            
        case .didAcknowledgeError:
            update { state in
                state.phase = .idle
            }
        }
    }
    
    private func search(_ searchText: String?) {
        update { state in
            state.searchText = searchText
            state.phase = .searching
        }
        getSearchResults(searchText) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
                
            case .success(let items):
                self.update { state in
                    state.items = items
                    state.phase = .idle
                }
            case .failure:
                self.update { state in
                    state.items = []
                    state.phase = .error(message: "Something went wrong")
                }
            }
        }
    }
    
    private func handleViewWillAppear() {
        if !state.viewDidAppear {
            batchUpdate { state in state.viewDidAppear = true }
            search(state.searchText)
        }
    }
    
}

class SearchViewController<Item: SearchListRepresentable & Equatable>: UIViewController, LassoView, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let store: SearchViewModule<Item>.ViewStore
    
    private let searchBar = UISearchBar()
    private let itemsTable = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .mediumGray)
    private weak var alertController: UIAlertController?
    
    init(store: SearchViewModule<Item>.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.dispatchAction(.viewWillAppear)
    }
    
    private func setUp() {
        
        func setUpConstraints() {
            [searchBar, itemsTable, activityIndicator].forEach({
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            })
            var constraints = [
                searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
                searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
                searchBar.heightAnchor.constraint(equalToConstant: 50),
                itemsTable.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                itemsTable.leftAnchor.constraint(equalTo: view.leftAnchor),
                itemsTable.rightAnchor.constraint(equalTo: view.rightAnchor),
                itemsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
                activityIndicator.leftAnchor.constraint(equalTo: view.leftAnchor),
                activityIndicator.rightAnchor.constraint(equalTo: view.rightAnchor),
                activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
            if #available(iOS 11.0, *) {
                constraints.append(searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
            } else {
                constraints.append(searchBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor))
            }
            NSLayoutConstraint.activate(constraints)
        }
        
        func setUpItemsTable() {
            itemsTable.dataSource = self
            itemsTable.delegate = self
            itemsTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
        
        func setUpSearchBar() {
            searchBar.delegate = self
        }
        
        func style() {
            view.backgroundColor = .background
        }
        
        setUpConstraints()
        setUpItemsTable()
        setUpSearchBar()
        style()
    }
    
    private func bind() {
        
        store.observeState(\.isLoading) { [activityIndicator] (_, isLoading) in
            if isLoading {
                if !activityIndicator.isAnimating { activityIndicator.startAnimating() }
            }
            else {
                if activityIndicator.isAnimating { activityIndicator.stopAnimating() }
            }
        }
        
        store.observeState(\.items) { [weak self] (_, _) in
            self?.itemsTable.reloadData()
        }
        
        store.observeState(\.searchText) { [searchBar] (_, searchText) in
            searchBar.text = searchText
        }
        
        store.observeState(\.error) { [weak self] (_, error) in
            if let error = error {
                if self?.alertController == nil {
                    self?.showError(error)
                }
            }
            else {
                if let alertController = self?.alertController {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    private func showError(_ error: String) {
        let alertController = UIAlertController(title: error, message: nil, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { [store] (_) in
            store.dispatchAction(.didAcknowledgeError)
        }
        alertController.addAction(continueAction)
        present(alertController, animated: true, completion: nil)
        self.alertController = alertController
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.state.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
        let item = store.state.items[indexPath.row]
        cell.textLabel?.text = item.searchListTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.dispatchAction(.didSelectItem(idx: indexPath.row))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        store.dispatchAction(.didUpdateSearchText(searchText))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        store.dispatchAction(.didPressClear)
    }
    
}

extension SearchScreenModule.State {
    
    var asViewState: SearchViewModule<Item>.ViewState {
        let error: String?
        switch phase {
        case .error(message: let message): error = message
        case .idle, .searching: error = nil
        }
        return SearchViewModule<Item>.ViewState(isLoading: phase == .searching, error: error, items: items, searchText: searchText)
    }
    
}
