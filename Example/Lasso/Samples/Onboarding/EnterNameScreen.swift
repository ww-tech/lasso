//
//===----------------------------------------------------------------------===//
//
//  EnterNameModule.swift
//
//  Created by Steven Grosmark on 5/13/19.
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

enum EnterNameScreenModule: ScreenModule {
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: EnterNameStore) -> Screen {
        let controller = EnterNameViewController(viewStore: store.asViewStore())
        return Screen(store, controller)
    }
    
    enum Action: Equatable {
        case didChange(_ name: String)
        case didTapNext
        case didTapRestart
    }
    
    enum Output: Equatable {
        case didTapNext
        case didTapRestart
    }
    
    struct State: Equatable {
        let title: String?
        var name: String
        var canProceed: Bool { return !name.isEmpty }
        
        init(title: String? = nil, name: String = "") {
            self.title = title
            self.name = name
        }
    }
    
}

class EnterNameStore: LassoStore<EnterNameScreenModule> {
    
    override func handleAction(_ action: Action) {
        switch action {
            
        case .didChange(let name):
            update { state in
                state.name = name
            }
            
        case .didTapNext: dispatchOutput(.didTapNext)
        case .didTapRestart: dispatchOutput(.didTapRestart)
        }
    }
}

class EnterNameViewController: UIViewController, LassoView {
    
    let store: EnterNameScreenModule.ViewStore
    
    private let titleLabel = UILabel()
    private let nameField = UITextField()
    private let nextButton = UIButton(standardButtonWithTitle: "Next")
    private let resetButton = UIButton(standardButtonWithTitle: "Start Over")
    
    init(viewStore: EnterNameScreenModule.ViewStore) {
        self.store = viewStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    private func setupViews() {
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = .systemFont(ofSize: 48, weight: .bold)
        titleLabel.text = store.state.title
        
        nameField.placeholder = "Enter your name"
        
        view.addSubviews(titleLabel, nameField, nextButton, resetButton)
    }
    
    private func setupConstraints() {
        titleLabel.layout
            .fill(.safeArea, except: .bottom, inset: 20)
        
        nameField.layout
            .below(titleLabel, offset: 50)
            .fillWidth(of: .safeArea, inset: 20, maximum: 300)
        
        nextButton.layout
            .below(nameField, offset: 50)
            .fillWidth(of: .safeArea, inset: 20, maximum: 300)
            .height(44)
        
        resetButton.layout
            .below(nextButton, offset: 20)
            .fillWidth(of: .safeArea, inset: 20, maximum: 300)
            .height(44)
    }
    
    private func setupBindings() {
        nextButton.bind(to: store, action: .didTapNext)
        resetButton.bind(to: store, action: .didTapRestart)
        
        nameField.bindTextDidChange(to: store) { .didChange($0) }
        
        store.observeState(\.name) { [weak self] name in
            self?.nameField.text = name
        }
        store.observeState { [weak self] state in
            self?.nextButton.isEnabled = state.canProceed
        }
    }
    
}
