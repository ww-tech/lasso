//
// ==----------------------------------------------------------------------== //
//
//  RandomItemFlow.swift
//
//  Created by Steven Grosmark on 5/27/19.
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

class RandomItemFlow: Flow<NoOutputNavigationFlow> {
    
    private let item: RandomItems.Item
    
    init(for item: RandomItems.Item) {
        self.item = item
    }
    
    override func createInitialController() -> UIViewController {
        let screen = TextScreenModule.createScreen(with: item.textState)
        screen.observeOutput { [weak self] in self?.handleScreenOutput($0) }
        
        screen.controller.title = item.name
        return screen.controller
    }
    
    private func handleScreenOutput(_ output: TextScreenModule.Output) {
        switch output {
            
        case .didTapButton:
            TextScreenModule
                .createScreen(with: TextScreenModule.State(description: .loremIpsum(paragraphs: 3)))
                .place(with: nextPushedInFlow)
        }
    }
}

extension RandomItems.Item {
    
    fileprivate var textState: TextScreenModule.State {
        if name.isEmpty, description.isEmpty {
            return TextScreenModule.State()
        }
        return TextScreenModule.State(title: name, description: description, buttons: ["More..."])
    }
    
}
