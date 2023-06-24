//
// ==----------------------------------------------------------------------== //
//
//  SubViewsShowcase.swift
//
//  Created by Steven Grosmark on 5/29/23
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2023 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import UIKit
import Lasso

/// Sample showing the use of a `ViewModule` to create a `ViewStore` to represent
/// a sub-set of another `Store`'s `State` and/or `Action`.
///
/// The `ViewModule`s are declared and used by the view controller to isolate a specific part of the `Store`.
final class SubViewsShowcase: ScreenModule {
    
    enum Action: Equatable {
        case didTapMute(_ mute: Bool)
        case didAdjustVolume(_ volume: Double)
    }
    
    struct State: Equatable {
        var muted: Bool = false
        var volume: Double = 0.5
    }
    
    static func createScreen(with store: SubViewsShowcaseStore) -> Screen {
        Screen(store, SubViewsShowcaseViewController(store: store.asViewStore()))
    }
    
    static var defaultInitialState: State { State() }
}

final class SubViewsShowcaseStore: LassoStore<SubViewsShowcase> {
    
    override func handleAction(_ action: Action) {
        switch action {
        
        case .didTapMute(let mute):
            update { state in
                state.muted = mute
            }
        
        case .didAdjustVolume(let volume):
            update { state in
                state.volume = min(1.0, max(0.0, volume))
            }
        }
    }
}
