//
// ==----------------------------------------------------------------------== //
//
//  RestScreen.swift
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
// ==----------------------------------------------------------------------== //
//

import UIKit
import Lasso

// MARK: - Module

enum RestScreenModule: ScreenModule {
    
    enum Action: Equatable {
        case didTapBackToWork
    }
    
    enum Output: Equatable {
        case didRestEnough
    }
    
    struct State: Equatable {
        let title: String = "Rest"
        let message: String = "Take a break"
    }
    
    static var defaultInitialState: State { State() }
    
    static func createScreen(with store: RestStore) -> Screen {
        Screen(store, RestViewController(store.asViewStore()))
    }
    
}

// MARK: - Store

final class RestStore: LassoStore<RestScreenModule> {
    
    override func handleAction(_ action: RestScreenModule.Action) {
        switch action {
            
        case .didTapBackToWork:
            dispatchOutput(.didRestEnough)
        }
    }
    
}

// MARK: - View

final class RestViewController: UIViewController, LassoView {
    
    let store: RestScreenModule.ViewStore
    
    init(_ store: RestScreenModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = state.title
        view.backgroundColor = .white
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = state.message
        
        let button = UIButton()
        button.setTitle("Feeling Rested", for: .normal)
        button.setTitleColor(view.tintColor, for: .normal)
        button.layer.borderColor = view.tintColor.cgColor
        button.layer.borderWidth = 2
        
        guard let view = view else { return }
        
        view.addSubview(button)
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        button.bind(to: store, action: .didTapBackToWork)
    }
    
}
