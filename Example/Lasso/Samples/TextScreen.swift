//
// ==----------------------------------------------------------------------== //
//
//  TextScreenModule.swift
//
//  Created by Trevor Beasty on 5/10/19.
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

enum TextScreenModule: PassthroughScreenModule {
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: PassthroughStore<TextScreenModule>) -> Screen {
        let controller = TextViewController(viewStore: store.asViewStore())
        return Screen(store, controller)
    }
    
    struct State: Equatable {
        let title: String?
        let description: String?
        let buttons: [String]
        
        init(title: String? = nil, description: String? = nil, buttons: [String] = []) {
            self.title = title
            self.description = description
            self.buttons = buttons
        }
    }
    
    enum Action: Equatable {
        case didTapButton(_ index: Int)
    }
    
    typealias Output = Action
    
}

class TextViewController: UIViewController, LassoView {
    
    let store: TextScreenModule.ViewStore
    
    init(viewStore: TextScreenModule.ViewStore) {
        self.store = viewStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        // set up labels
        let titleLabel = UILabel(headline: store.state.title)
        let descriptionLabel = UILabel(body: store.state.description)
        
        // arrange labels
        view.addSubviews(titleLabel, descriptionLabel)
        
        titleLabel.layout
            .fill(.safeArea, except: .bottom, inset: 20)
        
        descriptionLabel.layout
            .below(titleLabel, offset: 20)
            .fill(.safeArea, axis: .x, inset: 20)
        
        // add buttons
        var previous: UIView = descriptionLabel
        var offset: CGFloat = 50
        
        for (index, title) in store.state.buttons.enumerated() {
            let button = UIButton(standardButtonWithTitle: title)
            
            view.addSubview(button)
            
            button.layout
                .below(previous, offset: offset)
                .fillWidth(of: .safeArea, inset: 20, maximum: 300)
            
            button.bind(to: store, action: .didTapButton(index))
            previous = button
            offset = 20
        }
    }
    
}
