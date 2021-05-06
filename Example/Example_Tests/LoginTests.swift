//
// ==----------------------------------------------------------------------== //
//
//  LoginTests.swift
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

import XCTest
import LassoTestUtilities
@testable import Lasso_Example

class LoginFormTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<LoginScreenStore>()

    override func setUp() {
        super.setUp()
        store = LoginScreenStore()
    }
    
    func test_DefaultInitialState() {
        XCTAssertStateEquals(LoginScreenModule.State(
            username: "",
            password: "",
            canLogin: false,
            error: nil,
            phase: .idle))
    }

    func test_enterJustUsername() {
        // when - user enters a username
        store.dispatchAction(.didEditUsername("me"))
        
        // then - new value should be reflected in the state
        XCTAssertStateEquals(updatedMarker { state in
            state.username = "me"
            state.canLogin = false
        })
        
        // when - user taps "login"
        store.dispatchAction(.didTapLogin)
        
        // then - error
        XCTAssertStateEquals(updatedMarker { state in
            state.error = "Please enter your username and password"
        })
    }
    
    func test_enterJustPassword() {
        // when - user enters a username
        store.dispatchAction(.didEditPassword("secret"))
        
        // then - new value should be reflected in the state
        XCTAssertStateEquals(updatedMarker { state in
            state.password = "secret"
            state.canLogin = false
        })
        
        // when - user taps "login"
        store.dispatchAction(.didTapLogin)
        
        // then - error
        XCTAssertStateEquals(updatedMarker { state in
            state.error = "Please enter your username and password"
        })
    }
    
    func test_enterBoth() {
        // when - user enters u/p combo
        store.dispatchAction(.didEditUsername("me"))
        store.dispatchAction(.didEditPassword("secret"))
        
        // then - new value should be reflected in the state
        XCTAssertStateEquals(updatedMarker { state in
            state.username = "me"
            state.password = "secret"
            state.canLogin = true
        })
    }

}

#if swift(>=5.1)
class LoginTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<LoginScreenStore>()
    var mockService: MockLoginService!
    
    override func setUp() {
        super.setUp()
        
        // start with store in form filled out, ready to login state
        store = LoginScreenStore(with: LoginScreenModule.State(
            username: "myname",
            password: "pass",
            canLogin: true,
            error: nil,
            phase: .idle))
        
        mockService = MockLoginService()
        mock(LoginService.$shared, with: mockService)
    }
    
    func test_login() {
        // when - user taps "login"
        store.dispatchAction(.didTapLogin)
        
        // then - log service pinged, in busy state
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .busy
            state.canLogin = false
        })
        XCTAssertEqual(mockService.username, store.state.username)
        XCTAssertEqual(mockService.password, store.state.password)
        XCTAssertNotNil(mockService.completion)
        
        // when - double-tap
        let savedCompletion = mockService.completion
        mockService.completion = nil
        store.dispatchAction(.didTapLogin)
        
        // then - login service shouldn't be pinged again
        XCTAssertNil(mockService.completion)
        
        // when - successful login
        savedCompletion?(.success(()))
        
        // then - not busy anymore, output sent
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .idle
        })
        XCTAssertOutputs([.didLogin])
    }
    
    func test_loginFailure() {
        // when - user taps "login"
        store.dispatchAction(.didTapLogin)
        
        // when - successful login
        mockService.completion?(.failure(MockError.failed))
        
        // then - not busy anymore, output sent
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .idle
            state.error = "Invalid login"
        })
        XCTAssertOutputs([])
    }
    
    final class MockLoginService: LoginServiceProtocol {
        var username: String?
        var password: String?
        var completion: ((Result<Void, Error>) -> Void)?
        
        func login(_ username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            self.username = username
            self.password = password
            self.completion = completion
        }
    }
    
}
#endif
