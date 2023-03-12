//
// ==----------------------------------------------------------------------== //
//
//  Login.swift
//
//  Created by Steven Grosmark on 12/11/19.
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

enum LoginScreenModule: ScreenModule {
    
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
    
    static func createScreen(with store: LoginScreenStore) -> Screen {
        let controller = LoginViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
}

final class LoginScreenStore: LassoStore<LoginScreenModule> {
    
    override func handleAction(_ action: LoginScreenModule.Action) {
        switch action {
            
        case .didEditUsername(let username):
            update { state in
                state.username = username
                state.canLogin = !username.isEmpty && !state.password.isEmpty
            }
            
        case .didEditPassword(let password):
            update { state in
                state.password = password
                state.canLogin = !state.username.isEmpty && !password.isEmpty
            }
            
        case .didTapLogin:
            login()
        }
    }
    
    private func loginAsSideEffect() {
        // Imagine a method similar to `update { state in }`
        // that runs an async block, where that block's lifetime
        // represents the duration of a side-effect.
        asyncUpdate { store in
            await store.update { $0.phase = .busy }
            let result = await LoginService.shared.login()
            await store.update { $0.phase = .idle }
        }
    }
    
    private func login() {
        guard state.phase == .idle else { return }
        guard state.canLogin else {
            update { state in
                state.error = "Please enter your username and password"
            }
            return
        }
        
        // combine?
        startSideEffect()
            .update { state in // updateable state
                state.phase = .busy
            }
            .then { state in // read only state
                
            }
            .update { state in // updateable state
                state.phase = .idle
            }
        
        update { state in
            state.phase = .busy
            state.error = nil
            state.canLogin = false
        }
        
        LoginService.shared.login(state.username, password: state.password) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                
            case .success:
                self.update { state in
                    state.phase = .idle
                }
                self.dispatchOutput(.didLogin)
                
            case .failure:
                self.update { state in
                    state.phase = .idle
                    state.canLogin = !state.username.isEmpty && !state.password.isEmpty
                    state.error = "Invalid login"
                }
            }
        }
    }
    
    private func doSomething() async {
        
    }
}
