//
// ==----------------------------------------------------------------------== //
//
//  ViewModules.swift
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

import Foundation
import Lasso

/// Represents read-only access to a "volume" property.
///
/// Note: when an `Action` isn't declared in a module, the type defaults to `NoAction`.
/// This is equivalent to creating the `typealias`:
/// ```
/// typealias Action = NoAction
/// ```
enum ReadOnlyVolume: ViewModule {
    struct ViewState: Equatable {
        var volume: Double
    }
}

/// Represents read (view observations) / write (via dispatchAction) to a "volume" property.
enum ReadWriteVolume: ViewModule {
    enum ViewAction: Equatable {
        case didAdjustVolume(_ volume: Double)
    }
    
    struct ViewState: Equatable {
        var volume: Double
    }
}

/// Represents read (view observations) / write (via dispatchAction) to a "muted" property.
enum ToggleableMute: ViewModule {
    enum ViewAction: Equatable {
        case didTapMute(_ mute: Bool)
    }
    
    struct ViewState: Equatable {
        var muted: Bool
    }
}

// MARK: - Mappings from SubViewsShowcase

extension AnyViewStore where ViewState == SubViewsShowcase.State {
    
    /// Sets up a proxy ViewStore to represent the unidirectional data flow
    /// from a `SubViewsShowcase` to a `ReadOnlyVolume`.
    ///
    /// `SubViewsShowcase.State -> ReadOnlyVolume.ViewState`
    ///
    /// Since `ReadOnlyVolume`'s `ViewAction` == `NoAction`, only a `stateMap` is needed.
    func asReadOnlyVolumeViewStore() -> ReadOnlyVolume.ViewStore {
        asViewStore(
            for: ReadOnlyVolume.self,
            stateMap: {
                // create a ReadOnlyVolume.ViewState from a SubViewsShowcase.State
                ReadOnlyVolume.ViewState(volume: $0.muted ? 0 : $0.volume)
            }
        )
    }
}

extension AnyViewStore where ViewState == SubViewsShowcase.State, ViewAction == SubViewsShowcase.Action {
    
    /// Sets up a proxy ViewStore to represent the unidirectional data flow
    /// between a `SubViewsShowcase` to a `ReadWriteVolume`.
    ///
    /// ```
    /// SubViewsShowcase.State  -> ReadWriteVolume.ViewState
    /// SubViewsShowcase.Action <- ReadWriteVolume.ViewAction
    /// ```
    func asReadWriteVolumeViewStore() -> ReadWriteVolume.ViewStore {
        asViewStore(
            for: ReadWriteVolume.self,
            stateMap: {
                // Map a SubViewsShowcase.State to a ReadWriteVolume.ViewState
                ReadWriteVolume.ViewState(volume: $0.volume)
            },
            actionMap: { volumeAction in
                // Map a ReadWriteVolume.ViewAction to a SubViewsShowcase.Action
                switch volumeAction {
                case .didAdjustVolume(let volume):
                    return .didAdjustVolume(volume)
                }
            }
        )
    }
    
    func asToggleableMuteViewStore() -> ToggleableMute.ViewStore {
        asViewStore(
            for: ToggleableMute.self,
            stateMap: {
                // Map a SubViewsShowcase.State to a ToggleableMute.ViewState
                ToggleableMute.ViewState(muted: $0.muted)
            },
            actionMap: { muteAction in
                // Map a ToggleableMute.ViewAction to a SubViewsShowcase.Action
                switch muteAction {
                case .didTapMute(let mute):
                    return .didTapMute(mute)
                }
            }
        )
    }
}
