//
// ==----------------------------------------------------------------------== //
//
//  Login.swift
//
//  Created by Steven Grosmark on 03/26/2021
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

enum Login: ScreenModule {
    
    enum Action: Equatable {
        case didEditUsername(String)
        case didEditPassword(String)
        case didTapLogin
    }
    
    enum Output: Equatable {
        case didLogin
    }
    
    struct State: Equatable {
        var username: String = ""
        var password: String = ""
        var canLogin: Bool = false
        var error: String?
        var phase: Phase = .idle
        
        enum Phase { case idle, busy }
    }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: LoginStore) -> Screen {
        let view = LoginView(store: store.asViewStore())
        return Screen(store, view)
    }
}
