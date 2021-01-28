//
//===----------------------------------------------------------------------===//
//
//  SampleCatalog.swift
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
import Lasso

enum SampleCatalog: ScreenModule {
    
    static var defaultInitialState: State {
        return State(title: "Lasso Examples")
    }
    
    static func createScreen(with store: SampleCatalogStore) -> Screen {
        let controller = SampleCatalogViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
    enum Action: Equatable {
        case didSelectItem(item: CatalogItem)
    }
    
    enum Output: Equatable {
        case didSelectItem(item: CatalogItem)
    }
    
    struct State: Equatable {
        var title: String
        let sections: [Section]
        
        init(title: String) {
            self.title = title
            sections = Section.allCases
        }
    }
    
    enum Section: String, CaseIterable, CustomStringConvertible {
        case presentation
        case simple
        case fancy
        
        var items: [SampleCatalog.CatalogItem] {
            switch self {
            case .presentation: return [.presentationSimpleCounter, .presentationOnboarding]
            case .simple: return [.counter, .search, .randomItems, .bindings, .swiftuiBindings, .login]
            case .fancy: return [.tabs, .splitView, .foodOnboarding, .onboarding, .signup, .strangeFlow, .onTheFly, .windowTransition, .survey, .searchAndTrack, .myDay, .pageController]
            }
        }
        
        var description: String { return "\(self.rawValue)".capitalized }
    }
    
    enum CatalogItem: String, CustomStringConvertible {
        case bindings = "UIKit Bindings"
        case swiftuiBindings = "SwiftUI Bindings"
        case counter
        case foodOnboarding = "Food onboarding"
        case login
        case myDay = "My Day (Child View Controller Pattern)"
        case onboarding
        case onTheFly = "On the fly Flow (Onboarding -> Text)"
        case pageController = "Page Controller (Non-standard Flow ARC)"
        case presentationOnboarding = "welcome onboarding"
        case presentationSimpleCounter = "simple counter"
        case randomItems = "Random items"
        case search
        case searchAndTrack = "Search & Track"
        case signup = "Signup Flow"
        case splitView = "Split view"
        case strangeFlow = "Strange flow"
        case survey
        case tabs = "Tab bar controller"
        case windowTransition = "Window Transition"
        
        var description: String { return "\(self.rawValue)".capitalized }
    }
    
}

// MARK: - SampleCatalogStore

class SampleCatalogStore: LassoStore<SampleCatalog> {
    
    override func handleAction(_ action: Action) {
        switch action {
            
        case .didSelectItem(let item):
            dispatchOutput(.didSelectItem(item: item))
        }
    }
    
}
