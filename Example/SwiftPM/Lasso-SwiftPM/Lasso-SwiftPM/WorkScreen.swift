//
//===----------------------------------------------------------------------===//
//
//  WorkScreen.swift
//
//  Created by Steven Grosmark on 1/6/20.
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
import Lasso

// MARK: - Module

enum WorkScreenModule: ScreenModule {
    
    enum Action: Equatable {
        case didTapWork
        case didGetSomeRest
    }
    
    enum Output: Equatable {
        case didWorkEnough
    }
    
    struct State: Equatable {
        let title: String = "Work"
        var work: [String] = []
    }
    
    static var defaultInitialState: State { State() }
    
    static func createScreen(with store: WorkStore) -> Screen {
        Screen(store, WorkViewController(store.asViewStore()))
    }
    
}

// MARK: - Store

final class WorkStore: LassoStore<WorkScreenModule> {
    
    override func handleAction(_ action: Action) {
        switch action {
            
        case .didTapWork:
            update { state in
                state.work.append("work")
            }
            if state.work.count >= 5 {
                dispatchOutput(.didWorkEnough)
            }
            
        case .didGetSomeRest:
            update { state in
                state.work = []
            }
        }
    }
    
}

// MARK: - View

final class WorkViewController: UIViewController, LassoView {
    
    let store: WorkScreenModule.ViewStore
    
    init(_ store: WorkScreenModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = state.title
        view.backgroundColor = .white
        
        let button = UIButton()
        button.setTitle("Work", for: .normal)
        button.setTitleColor(view.tintColor, for: .normal)
        button.layer.borderColor = view.tintColor.cgColor
        button.layer.borderWidth = 2
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        guard let view = view else { return }
        
        view.addSubview(button)
        view.addSubview(label)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 30),
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30)
        ])
        
        store.observeState(\.work) { [weak label] work in
            label?.text = work.joined(separator: "\n")
        }
        button.bind(to: store, action: .didTapWork)
    }
    
}
