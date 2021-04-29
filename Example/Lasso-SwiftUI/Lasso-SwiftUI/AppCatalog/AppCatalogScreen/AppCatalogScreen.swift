//
// ==----------------------------------------------------------------------== //
//
//  AppCatalogScreen.swift
//
//  Created by Steven Grosmark on 03/23/2021.
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

enum AppCatalogScreen: ScreenModule {
    
    struct State: Equatable {
        let title: String
        let sections: [Section]
    }
    
    enum Section: SelfIdentifiable, TitleConvertible {
        
        case screens
        case flows
        
        var items: [Item] {
            switch self {
            case .screens: return [.simpleCounter, .login]
            case .flows: return [.welcome]
            }
        }
        
        enum Item: SelfIdentifiable, TitleConvertible {
            case simpleCounter, login
            case welcome
        }
    }
    
    typealias Action = Section.Item
    typealias Output = Action
    
    static func createScreen(with store: AppCatalogStore) -> Screen {
        Screen(store, AppCatalogView(store: store.asViewStore()))
    }
    
    static var defaultInitialState: State { State(title: "Lasso ❤️ SwiftUI", sections: [.screens, .flows]) }
}

final class AppCatalogStore: LassoStore<AppCatalogScreen> {
    
    override func handleAction(_ action: Action) {
        dispatchOutput(action)
    }
}
