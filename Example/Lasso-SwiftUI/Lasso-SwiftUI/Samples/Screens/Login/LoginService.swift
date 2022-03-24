//
// ==----------------------------------------------------------------------== //
//
//  LoginService.swift
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

protocol LoginServiceProtocol {
    func login(_ username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

struct LoginService: LoginServiceProtocol {
    
    @Mockable static private(set) var shared: LoginServiceProtocol = LoginService()
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    func login(_ username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let isLoggedIn = Int.random(in: 0...100) < LoginService.successRate
            switch isLoggedIn {
            case true: completion(.success(()))
            case false: completion(.failure(LoginError.invalidCredentials))
            }
        }
    }
    
    /// Chance of success, from 0 through 100 percent
    static var successRate: Int = 50
    
}
