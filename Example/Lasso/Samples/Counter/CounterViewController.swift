//
// ==----------------------------------------------------------------------== //
//
//  CounterViewController.swift
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
// ==----------------------------------------------------------------------== //
//

import UIKit
import WWLayout
import Lasso

class CounterViewController: UIViewController, LassoView {
    
    let store: CounterScreenModule.ViewStore
    
    init(store: CounterScreenModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = store.state.style.backgroundColor
        
        let titleLabel = UILabel(headline: store.state.title)
        
        let decrementButton = UIButton(type: .system).set(title: "-", with: .systemFont(ofSize:32))
        let incrementButton = UIButton(type: .system).set(title: "+", with: .systemFont(ofSize:32))
        
        let display = UILabel()
        display.font = .systemFont(ofSize: 64, weight: .bold)
        display.textAlignment = .center
        display.backgroundColor = store.state.style.counterColor
        display.set(cornerRadius: 11)
        
        let nextButton = UIButton(standardButtonWithTitle: "Next")
        
        view.addSubviews(titleLabel, decrementButton, display, incrementButton, nextButton)
        
        titleLabel.layout
            .fill(.safeArea, except: .bottom, inset: 20)
        
        decrementButton.layout
            .leading(to: .safeArea, offset: 20)
            .centerY(to: .safeArea)
            .size(44)
        
        incrementButton.layout
            .trailing(to: .safeArea, offset: -20)
            .centerY(to: .safeArea)
            .size(44)
        
        display.layout
            .leading(to: decrementButton, edge: .trailing, offset: 20)
            .trailing(to: incrementButton, edge: .leading, offset: -20)
            .height(toWidth: 1.0, priority: .high)
            .top(.greaterOrEqual, to: titleLabel, edge: .bottom, offset: 20)
            .bottom(.lessOrEqual, to: nextButton, edge: .top, offset: -20)
            .centerY(to: .safeArea)
        
        nextButton.layout
            .fillWidth(of: .safeArea, inset: 20, maximum: 300)
            .bottom(to: .safeArea, edge: .bottom, offset: -20)
        
        decrementButton.bind(to: store, action: .didTapDecrement)
        incrementButton.bind(to: store, action: .didTapIncrement)
        nextButton.bind(to: store, action: .didTapNext)
        
        store.observeState(\.counter) { value in
            display.text = "\(value)"
        }
    }
    
}

extension CounterScreenModule.State.Style {
    
    fileprivate var backgroundColor: UIColor {
        switch self {
        case .light: return .white
        case .dark: return .lightGray
        case .purple: return .lightGray
        }
    }
    
    fileprivate var counterColor: UIColor {
        switch self {
        case .light: return .lightGray
        case .dark: return .white
        case .purple: return .purple
        }
    }
}
