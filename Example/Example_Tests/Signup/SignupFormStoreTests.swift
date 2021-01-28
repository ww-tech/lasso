//
// ==----------------------------------------------------------------------== //
//
//  SignupFormStoreTests.swift
//
//  Created by Steven Grosmark on 10/5/19.
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

class SignupFormStoreTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<SignupFormStore>()

    typealias Validated = SignupForm.Validated
    
    override func setUp() {
        super.setUp()
        store = Store(with: State())
    }

    func test_DefaultInitialState() {
        // test the default State initializer - a.k.a. the "given" state for all the other states
        for field in SignupForm.Field.allCases {
            XCTAssertEqual(store.state[keyPath: field.stateKey], Validated(value: "", error: nil))
        }
        XCTAssertEqual(store.state.phase, .idle)
        XCTAssertEqual(store.state.formIsValid, false)
    }
    
    func test_Invalid() {
        for field in SignupForm.Field.allCases {
            for value in field.invalidEntries {
                
                // when - update field with invalid value
                store.dispatchAction(.didUpdate(field, value))
                
                // then - field should be marked as invalid
                XCTAssertStateEquals(updatedMarker { state in
                    state[keyPath: field.stateKey] = Validated(value: value, error: "Invalid")
                })
            }
        }
    }
    
    func test_Valid() {
        for field in SignupForm.Field.allCases {
            for value in field.validEntries {
                
                // when - update field with valid value
                store.dispatchAction(.didUpdate(field, value))
                
                // then - field should be marked as valid,
                // and if this is the password field, the form should now be valid
                XCTAssertStateEquals(updatedMarker { state in
                    state[keyPath: field.stateKey] = Validated(value: value, error: nil)
                    state.formIsValid = field == .password
                })
                
                // when - update field with valid value surrounded by whitespace
                store.dispatchAction(.didUpdate(field, " \t\n\(value) \t\n"))
                
                // then - whitespace should be stripped, & field marked as valid
                XCTAssertStateEquals(updatedMarker { state in
                    state[keyPath: field.stateKey] = Validated(value: value, error: nil)
                })
            }
        }
    }
    
    func test_Submit_Invalid() {
        // when - tap signup w/invalid form
        store.dispatchAction(.didTapSignup)
        
        // then - no outputs or state change
        XCTAssertOutputs([])
        XCTAssertStateEquals(markerState)
    }

}

class SignupFormStoreSubmitTests: XCTestCase, LassoStoreTestCase {
    
    let testableStore = TestableStore<SignupFormStore>()
    
    let validFields = SignupForm.Output.Fields(name: "billie", email: "b@bb.ie", username: "billie", password: "billie")
    
    private var mockService = MockSignupService()
    
    override func setUp() {
        super.setUp()
        store = Store(with: State(from: validFields))
        mockService = MockSignupService()
        store.signupService = mockService
    }
    
    func test_Submit() {
        // given
        XCTAssertEqual(store.state.formIsValid, true)
        XCTAssertEqual(store.state.completedFields, validFields)
        
        // when - tap signup w/valid form
        store.dispatchAction(.didTapSignup)
        
        // then - form should be processing, no output yet
        XCTAssertStateEquals(updatedMarker { state in
            state.phase = .working
        })
        XCTAssertNotNil(mockService.completion)
        XCTAssertOutputs([])
        
        // when - call completion
        mockService.completion?(.success("test"))
        
        // then - output with validated fields
        XCTAssertOutputs([.didSignup(validFields)])
    }
    
    func test_NoDoubleSubmit() {
        // given - valid form has been submitted
        store.update { state in
            state.phase = .working
        }
        syncState()
        
        // when - tap signup w/valid form, already being submitted
        store.dispatchAction(.didTapSignup)
        
        // then - no outputs or state change, or completion handler
        XCTAssertOutputs([])
        XCTAssertStateEquals(markerState)
        XCTAssertNil(mockService.completion)
    }
    
}

extension SignupForm.Field {
    
    var invalidEntries: [String] {
        switch self {
        case .name: return ["a", "aa", String(repeating: "a", count: 100)]
        case .email: return ["as@as.", "asd.com", "jhg@.com", "jhg"]
        case .username: return ["a", "aa", String(repeating: "a", count: 100), "aaa*****"]
        case .password: return ["a", "aa", String(repeating: "a", count: 100)]
        }
    }
    
    var validEntries: [String] {
        switch self {
        case .name: return ["abc", "123", String(repeating: "a", count: 64)]
        case .email: return ["pat@hope.abc", "Gavin@hoolie.io"]
        case .username: return ["abc123_", "__3"]
        case .password: return ["abc", "123", "!@#$%^&*()))+_", String(repeating: "a", count: 64)]
        }
    }
    
}

private final class MockSignupService: SignupServiceProtocol {
    var completion: ((Result<String, Error>) -> Void)?
    
    func signup(_ fields: SignupForm.Output.Fields, completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
    }
}
