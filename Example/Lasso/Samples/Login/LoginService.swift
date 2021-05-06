//
// ==----------------------------------------------------------------------== //
//
//  LoginService.swift
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

import Foundation
import Lasso

protocol LoginServiceProtocol {
    func login(_ username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

struct LoginService: LoginServiceProtocol {
    
    #if swift(>=5.1)
        @Mockable static private(set) var shared: LoginServiceProtocol = LoginService()
    #else
        static let shared: LoginServiceProtocol = LoginService()
    #endif
    
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
    static var successRate: Int = 100
    
}
