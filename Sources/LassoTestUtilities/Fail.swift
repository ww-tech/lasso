//
// ==----------------------------------------------------------------------== //
//
//  Fail.swift
//
//  Created by Trevor Beasty on 8/16/19.
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

/// Describes the side effect of a test failure
public typealias FailTest = (FailedTest) -> TestFailureAction

public struct FailedTest {
    let error: LassoError
    let file: StaticString
    let line: UInt
    let verbose: Bool
    
    init(error: LassoError, file: StaticString, line: UInt, verbose: Bool = false) {
        self.error = error
        self.file = file
        self.line = line
        self.verbose = verbose
    }
    
}

/// Logs error messages at the call site on test failure.
public let log = { (failedTest: FailedTest) -> TestFailureAction in
    
    let message = failedTest.error.message(verbose: failedTest.verbose)
    
    return TestFailureAction(failedTest: failedTest) {
        XCTFail(message, file: failedTest.file, line: failedTest.line)
    }
    
}

/// Does nothing on test failure - needed to test that tests fail appropriately.
internal let silent = { (failedTest: FailedTest) -> TestFailureAction in
    
    return TestFailureAction(failedTest: failedTest) { }
    
}

/// An error with a message.
public protocol LassoError: Error {
    func message(verbose: Bool) -> String
}

extension LassoError {
    
    var message: String {
        return message(verbose: false)
    }
    
}

/// An error that invokes an action upon initialization.
/// This abstraction is needed to make assertions of the form "this test should fail".
public struct TestFailureAction: Error {
    
    let failedTest: FailedTest
    
    public init(failedTest: FailedTest, action: () -> Void) {
        self.failedTest = failedTest
        action()
    }
}

enum ModalPresentationError: LassoError {
    case unexpectedModallyForemostPrecedingEvent(expected: UIViewController, realized: UIViewController)
    case unexpectedModallyForemostFollowingEvent(expected: [UIViewController], realized: [UIViewController])
    case noPresentationOccurred
    case noDismissalOccurred
    case unexpectedModalPresentationStyle(expected: UIModalPresentationStyle, realized: UIModalPresentationStyle)
    
    func message(verbose: Bool) -> String {
        switch self {
            
        case .unexpectedModallyForemostPrecedingEvent(expected: let expected, realized: let realized):
            var main = "unexpected modally foremost preceding event"
            if verbose {
                main += " \(describeViewControllerHierarchy(realized))"
            }
            return main + formattedText(describing: (expectedKey, expected), (realizedKey, realized))
            
        case .unexpectedModallyForemostFollowingEvent(expected: let expected, realized: let realized):
            var main = "unexpected modally foremost following event"
            if verbose, let first = realized.first {
                main += " \(describeViewControllerHierarchy(first))"
            }
            return main + formattedText(describing: (expectedKey, expected), (realizedKey, realized))
            
        case .noPresentationOccurred:
            return "no presentation occurred"
            
        case .noDismissalOccurred:
            return "no dismissal occurred"
            
        case .unexpectedModalPresentationStyle(expected: let expected, realized: let realized):
            return "unexpected modal transition style" + formattedText(describing: (expectedKey, expected.rawValue), (realizedKey, realized.rawValue))
        }
    }
    
}

enum ModalPresentationTypeError<Type>: LassoError {
    case unexpectedPresentedTypeFollowingEvent(realized: UIViewController)
    
    func message(verbose: Bool) -> String {
        switch self {
            
        case .unexpectedPresentedTypeFollowingEvent(realized: let realized):
            return "expected presented to be of type \(String(describing: Type.self)), instead found \(String(describing: type(of: realized)))"
        }
    }
    
}

enum NavigationPresentationError: LassoError {
    case noNavigationEmbedding(target: UIViewController)
    case unexpectedTopPrecedingEvent(expected: UIViewController, navigationController: UINavigationController)
    case unexpectedEmptyStackFollowingEvent(navigationController: UINavigationController)
    case unexpectedTopFollowingEvent(expected: UIViewController, navigationController: UINavigationController)
    case unexpectedTopStackFollowingEvent(expected: [UIViewController], navigationController: UINavigationController)
    case unexpectedStackFollowingRootEvent(navigationController: UINavigationController)
    case oldRootRemainsFollowingRootEvent(oldRoot: UIViewController, navigationController: UINavigationController)
    case noPushOccurred(previous: UIViewController)
    
    func message(verbose: Bool) -> String {
        switch self {
            
        case .noNavigationEmbedding(target: let target):
            return "nil navigation controller for controller" + formattedText(describing: (controllerKey, target))
            
        case .unexpectedTopPrecedingEvent(expected: let expected, navigationController: let nav):
            return "expected controller to be at top of navigation stack preceding event" + formattedText(describing: (controllerKey, expected), (navKey, nav))
            
        case .unexpectedEmptyStackFollowingEvent(navigationController: let nav):
            return "expected non-empty navigation stack following event" + formattedText(describing: (navKey, nav))
            
        case .unexpectedTopFollowingEvent(expected: let expected, navigationController: let nav):
            return "expected controller to be at top of navigation stack following event" + formattedText(describing: (controllerKey, expected), (navKey, nav))
            
        case .unexpectedTopStackFollowingEvent(expected: let expected, navigationController: let nav):
            return "expected controllers to be at top of navigation stack following event" + formattedText(describing: (controllersKey, expected), (navKey, nav))
            
        case .unexpectedStackFollowingRootEvent(navigationController: let nav):
            return "unexpected navigation stack following event" + formattedText(describing: (navKey, nav), (stackKey, nav.viewControllers))
            
        case .oldRootRemainsFollowingRootEvent(oldRoot: let oldRoot, navigationController: let nav):
            return "expected new root following event" + formattedText(describing: ("old root", oldRoot), (navKey, nav))
            
        case .noPushOccurred(previous: let previous):
            return "no push occurred\nRealized: 'previous' \(String(describing: previous)) at top of navigation stack following event"
        }
    }
    
}

enum NavigationPresentationTypeError<Type>: LassoError {
    case unexpectedPushedType(realized: UIViewController)
    case unexpectedRootType(realized: UIViewController)
    
    func message(verbose: Bool) -> String {
        switch self {
            
        case .unexpectedPushedType(realized: let realized):
            return "expected pushed to be of type \(String(describing: Type.self))" + formattedText(describing: ("Realized pushed", realized))
            
        case .unexpectedRootType(realized: let realized):
            return "expected root to be of type \(String(describing: Type.self))" + formattedText(describing: ("Realized root", realized))
        }
    }
    
}

enum TypeCastError<Instance, Type>: Error {
    case failedToResolveInstance
    case unexpectedInstanceType(instance: Instance)
}

extension XCTest {
    
    internal func unexpectedErrorType(file: StaticString = #file, line: UInt = #line) {
        XCTFail("unexpected error type", file: file, line: line)
    }
    
    internal func assertThrowsError(expr: () throws -> Void, eval: (LassoError) -> Void, file: StaticString = #file, line: UInt = #line) {
        do {
            try expr()
        }
        catch let error {
            guard let testFailureAction = error as? TestFailureAction else { fatalError("should always be of type TestFailureAction") }
            eval(testFailureAction.failedTest.error)
            return
        }
        XCTFail("expected error to be thrown", file: file, line: line)
    }
    
}

private let navKey = "navigation controller"
private let targetKey = "target"
private let controllersKey = "controllers"
private let controllerKey = "controller"
private let expectedKey = "expected"
private let realizedKey = "realized"
private let stackKey = "stack"

private func formattedText(describing pairs: (String, CustomStringConvertible)...) -> String {
    return pairs.map { "\n\($0.0): \(String(describing: $0.1))" }
        .joined()
}
