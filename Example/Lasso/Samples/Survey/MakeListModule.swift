//
// ==----------------------------------------------------------------------== //
//
//  MakeListModule.swift
//
//  Created by Trevor Beasty on 6/4/19.
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

enum MakeListViewModule: ViewModule {
    
    struct ViewState: Equatable {
        var header: String
        var placeholder: String
        var proposed: String?
        var submitted: [String]
    }
    
    enum ViewAction: Equatable {
        case didEditProposed(String?)
        case didPressSubmit
        case didPressAdd
    }
    
}

class MakeListViewController: UIViewController, LassoView {
    
    private let headerLabel = UILabel()
    private let field = UITextField()
    private let table = UITableView()
    private let addButton = UIButton()
    private let submitButton = UIButton()
    
    let store: MakeListViewModule.ViewStore
    
    init(store: MakeListViewModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        bind()
    }
    
    private func setUp() {
        setUpConstraints()
        setUpTable()
        setUpInteractions()
        configureStaticValues()
        style()
    }
    
    private func setUpConstraints() {
        view.addSubviews(headerLabel, field, addButton, table, submitButton)
        
        headerLabel.layout
            .fill(.superview, axis: .x, inset: 20)
            .top(to: .safeArea, offset: 20)
        
        addButton.layout
            .left(to: field, edge: .right, offset: 10)
            .right(to: .superview, offset: -20)
            .centerY(to: field)
        addButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        field.layout
            .top(to: headerLabel, edge: .bottom, offset: 20)
            .left(to: .superview, offset: 20)
            .height(50)
        
        table.layout
            .top(to: field, edge: .bottom, offset: 20)
            .fill(.superview, axis: .x, inset: 20)
            .bottom(to: submitButton, edge: .top, offset: -20)
        
        submitButton.layout
            .bottom(to: .safeArea, offset: -20)
            .fill(.superview, axis: .x, inset: 20)
            .height(50)
    }
    
    private func setUpTable() {
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    private func setUpInteractions() {
        submitButton.addTarget(self, action: #selector(didPressSubmit), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(didPressAdd), for: .touchUpInside)
        field.addTarget(self, action: #selector(didEditProposed), for: .editingChanged)
    }
    
    private func configureStaticValues() {
        addButton.setTitle("Add", for: .normal)
        submitButton.setTitle("Submit", for: .normal)
    }
    
    private func style() {
        view.backgroundColor = .background
        headerLabel.textAlignment = .left
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        addButton.backgroundColor = .white
        addButton.setTitleColor(.blue, for: .normal)
        submitButton.backgroundColor = .blue
        submitButton.setTitleColor(.white, for: .normal)
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1.0
    }
    
    private func bind() {
        
        store.observeState(\.proposed) { [weak self] proposed in
            self?.field.text = proposed
        }
        
        store.observeState(\.submitted) { [weak self] _ in
            self?.table.reloadData()
        }
        
        store.observeState(\.header) { [weak self] header in
            self?.headerLabel.text = header
        }
        
        store.observeState(\.placeholder) { [weak self] placeholder in
            self?.field.placeholder = placeholder
        }
        
    }
    
    @objc private func didPressSubmit() {
        store.dispatchAction(.didPressSubmit)
    }
    
    @objc private func didPressAdd() {
        store.dispatchAction(.didPressAdd)
    }
    
    @objc private func didEditProposed() {
        store.dispatchAction(.didEditProposed(field.text))
    }
    
}

extension MakeListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.state.submitted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let submission = store.state.submitted[indexPath.row]
        cell.textLabel?.text = submission
        return cell
    }
    
}
