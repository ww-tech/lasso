//
// ==----------------------------------------------------------------------== //
//
//  LifeCycleController.swift
//
//  Created by Trevor Beasty on 8/8/19.
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

class LifeCycleController: UIViewController {
    
    enum LifeCycleEvent: Hashable, CaseIterable {
        case viewDidLoad
        case viewWillAppear
        case viewDidAppear
        case viewWillDisappear
        case viewDidDisappear
    }
    
    var lifeCycleEvents: [LifeCycleEvent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "LifeCycleController"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
                                     view.centerYAnchor.constraint(equalTo: label.centerYAnchor)])
        lifeCycleEvents.append(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifeCycleEvents.append(.viewWillAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lifeCycleEvents.append(.viewDidAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lifeCycleEvents.append(.viewWillDisappear)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifeCycleEvents.append(.viewDidDisappear)
    }
    
}
