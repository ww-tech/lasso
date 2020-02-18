//
//===----------------------------------------------------------------------===//
//
//  Mockable.swift
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
//===----------------------------------------------------------------------===//
//

import Foundation

#if swift(>=5.1)

/// Property wrapper for allowing things to be mocked for unit test purposes.
///
/// Mark a property as `@Mockable`:
/// ```
/// enum Services {
///   @Mockable static var auth: AuthServiceProtocol = AuthService()
/// }
/// ```
///
/// `@Mockable` properties are used as plain properties in production code:
/// ```
/// Services.auth.login(username, password) { success in ... }
/// ```
///
/// A property can be mocked by accessing it's projected  (`$`) value:
/// ```
/// // set up the mock:
/// Services.$auth.mock(with: MockAuthService())
///
/// // run some tests
///
/// // remove the mock:
/// Services.$auth.reset()
/// ```
///
/// Better yet, use the `XCTestCase` in `LassoTestUtilities` to handle resetting mocks automatically:
/// ```
/// func test_something() {
///   mock(Services.$auth, with: MockAuthService())
///   // run some tests
/// }
/// ```
@propertyWrapper
public struct Mockable<T> {
    
    /// Current, public-facing value.  Will either be the mocked value, or the default value.
    public var wrappedValue: T {
        get { return projectedValue.value }
        set { projectedValue.value = newValue }
    }
    
    public init(wrappedValue: T) {
        self.projectedValue = Projected(wrappedValue)
    }
    
    /// The value returned when accessing the wrapper using `$` notation
    public let projectedValue: Projected
    
    public final class Projected {
        
        /// A `Mockable` value can only be mocked when running tests.
        public func mock(with mock: @autoclosure () -> T?) {
            mocked = Testing.active ? mock() : nil
        }
        public func reset() {
            mocked = nil
        }
        
        fileprivate var value: T {
            get { return mocked ?? _value }
            set { _value = newValue }
        }
        
        private var _value: T
        private var mocked: T?
        
        fileprivate init(_ value: T) {
            _value = value
        }
    }
    
}

#endif

public enum Testing {
    
    /// Is the current code running under a unit test environment - i.e. is XCTestCase present?
    public static internal(set) var active: Bool = { return NSClassFromString("XCTestCase") != nil }()
    
}
