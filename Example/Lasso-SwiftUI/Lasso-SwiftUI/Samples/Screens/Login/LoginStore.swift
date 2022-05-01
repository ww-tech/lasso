//
// ==----------------------------------------------------------------------== //
//
//  LoginStore.swift
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

import Foundation
import Lasso

final class LoginStore: LassoStore<Login> {
    
    override func handleAction(_ action: Action) {
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
    
    private func login() {
        guard state.phase == .idle else { return }
        guard state.canLogin else {
            update { state in
                state.error = "Please enter your username and password"
            }
            return
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
}
