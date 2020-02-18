//
//===----------------------------------------------------------------------===//
//
//  SampleCatalogViewController.swift
//
//  Created by Steven Grosmark on 5/9/19.
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

import UIKit
import WWLayout
import Lasso

class SampleCatalogViewController: UIViewController, LassoView {
    
    private let tableView: UITableView
    let store: SampleCatalog.ViewStore
    
    init(store: SampleCatalog.ViewStore) {
        self.tableView = UITableView()
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        edgesForExtendedLayout = UIRectEdge()
        
        store.observeState(\.title) { [weak self] title in
            self?.title = title
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .background
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(type: UITableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.layout.fill(.safeArea)
    }
}

extension SampleCatalogViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return store.state.sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.state.sections[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return store.state.sections[section].description
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = store.state.sections[indexPath.section]
        let cell = tableView.dequeueCell(type: UITableViewCell.self, indexPath: indexPath)
        cell.textLabel?.text = section.items[indexPath.row].description
        return cell
    }
}

extension SampleCatalogViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = store.state.sections[indexPath.section]
        let item = section.items[indexPath.row]
        store.dispatchAction(.didSelectItem(item: item))
    }
}
