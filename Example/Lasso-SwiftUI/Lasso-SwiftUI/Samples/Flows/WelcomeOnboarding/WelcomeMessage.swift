//
// ==----------------------------------------------------------------------== //
//
//  WelcomeMessage.swift
//
//  Created by Steven Grosmark on 03/25/2021
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2021 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import UIKit
import SwiftUI
import Lasso

enum WelcomeMessage: PassthroughScreenModule {
    
    struct State: Equatable {
        let text: String
        
        init(text: String = "") {
            self.text = text
        }
    }
    
    enum Action: Equatable {
        case didTapNext
    }
    typealias Output = Action
    
    static var defaultInitialState: State { State() }
    
    static func createScreen(with store: PassthroughStore<WelcomeMessage>) -> Screen {
        let controller = WelcomeMessageView(store: store.asViewStore())
        return Screen(store, controller)
    }
}
