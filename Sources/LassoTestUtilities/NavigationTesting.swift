//
// ==----------------------------------------------------------------------== //
//
//  NavigationTesting.swift
//
//  Created by Trevor Beasty on 8/13/19.
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

public extension XCTestCase {
    
    // swiftlint:disable function_body_length
    
    /// Assert that the event will result in a push in the navigation controller of the previous controller.
    /// The previous and pushed controllers receive the full set of lifecycle hooks.
    /// CRITICAL: Controllers must be descendants of a UIWindow which is 'key and visible', otherwise,
    /// lifecycle hooks will not work.
    /// 1) the previous controller must be embedded in a navigation controller
    /// 2) the previous controller must be at the top of the navigation stack preceding the event
    /// 3) the previous and pushed controllers must be at the top of the navigation stack following the event
    /// - Parameter previous: the controller at the top of the navigation stack to be pushed on
    /// - Parameter event: the event which triggers the push
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear and viewWillDisappear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear and viewDidDisappear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    /// - Parameter failTest: the side effect of test failure
    func assertPushed<Previous: UIViewController, Pushed: UIViewController>(
        after previous: Previous,
        when event: () -> Void,
        timeout: TimeInterval? = nil,
        onViewDidLoad: (Previous, Pushed) -> Void = { _, _ in },
        onViewWillAppear: @escaping (Previous, Pushed) -> Void = { _, _ in },
        onViewDidAppear: @escaping (Previous, Pushed) -> Void = { _, _ in },
        file: StaticString = #file,
        line: UInt = #line,
        failTest: FailTest = log
    ) throws -> Pushed {
        
        guard let nav = previous.navigationController else {
            throw failTest(FailedTest(
                error: NavigationPresentationError.noNavigationEmbedding(target: previous),
                file: file,
                line: line
            ))
        }
        guard nav.viewControllers.suffix(1) == [previous] else {
            throw failTest(FailedTest(
                error: NavigationPresentationError.unexpectedTopPrecedingEvent(expected: previous, navigationController: nav),
                file: file,
                line: line
            ))
        }
        
        do {
            return try assertControllerEvent(
                from: previous,
                to: {
                    guard let newTop = nav.topViewController else {
                        throw NavigationPresentationError.unexpectedEmptyStackFollowingEvent(navigationController: nav)
                    }
                    guard !(newTop === previous) else {
                        throw NavigationPresentationError.noPushOccurred(previous: previous)
                    }
                    guard nav.viewControllers.suffix(2) == [previous, newTop] else {
                        throw NavigationPresentationError.unexpectedTopStackFollowingEvent(expected: [previous, newTop], navigationController: nav)
                    }
                    return newTop
                },
                when: event,
                timeout: timeout,
                onViewDidLoad: onViewDidLoad,
                onViewWillAppear: onViewWillAppear,
                onViewDidAppear: onViewDidAppear,
                file: file,
                line: line
            )
        }
        catch let error {
            switch error {
                
            case TypeCastError<UIViewController, Pushed>.unexpectedInstanceType(instance: let instance):
                throw failTest(FailedTest(
                    error: NavigationPresentationTypeError<Pushed>.unexpectedPushedType(realized: instance),
                    file: file,
                    line: line
                ))
                
            default:
                guard let lassoError = error as? LassoError else { fatalError("should never execute") }
                throw failTest(FailedTest(error: lassoError, file: file, line: line))
            }
        }
    }
    // swiftlint:enable function_body_length
    
    /// Assert that the event will result in a new root for the navigation controller, where the new root
    /// is the only controller in the navigation stack. The new root receives the full set of lifecycle hooks.
    /// CRITICAL: Controllers must be descendants of a UIWindow which is 'key and visible', otherwise,
    /// lifecycle hooks will not work.
    /// 1) a new root must be set
    /// 2) the new root must be the only controller in the navigation stack following the event
    /// - Parameter nav: the navigation controller which will be configured
    /// - Parameter event: the event which triggers the setting of the root
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    /// - Parameter failTest: the side effect of test failure
    func assertRoot<Root: UIViewController>(
        of nav: UINavigationController,
        when event: () -> Void,
        timeout: TimeInterval? = nil,
        onViewDidLoad: (Root) -> Void = { _ in },
        onViewWillAppear: @escaping (Root) -> Void = { _ in },
        onViewDidAppear: @escaping (Root) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line,
        failTest: FailTest = log
    ) throws -> Root {
        let precedingRoot = nav.viewControllers.first
        do {
            return try assertControllerEvent(
                to: {
                    guard let root = nav.viewControllers.first, nav.viewControllers == [root] else {
                        throw NavigationPresentationError.unexpectedStackFollowingRootEvent(navigationController: nav)
                    }
                    return root
            },
                when: event,
                timeout: timeout,
                onViewDidLoad: onViewDidLoad,
                onViewWillAppear: onViewWillAppear,
                onViewDidAppear: onViewDidAppear,
                file: file,
                line: line
            )
        }
        catch let error {
            switch error {
                
            case TypeCastError<UIViewController, Root>.unexpectedInstanceType(instance: let instance):
                if let precedingRoot = precedingRoot, instance === precedingRoot {
                    let failedTest = FailedTest(error: NavigationPresentationError.oldRootRemainsFollowingRootEvent(oldRoot: precedingRoot, navigationController: nav),
                                                file: file,
                                                line: line)
                    throw failTest(failedTest)
                }
                let failedTest = FailedTest(error: NavigationPresentationTypeError<Root>.unexpectedRootType(realized: instance),
                                            file: file,
                                            line: line)
                throw failTest(failedTest)
                
            default:
                guard let lassoError = error as? LassoError else {
                    fatalError("should never execute")
                }
                let failedTest = FailedTest(error: lassoError,
                                            file: file,
                                            line: line)
                throw failTest(failedTest)
            }
        }
    }
    
    /// Assert that the event will result in a pop in the navigation controller.
    /// The old and new top controllers receive the full set of lifecycle hooks.
    /// CRITICAL: Controllers must be descendants of a UIWindow which is 'key and visible', otherwise,
    /// lifecycle hooks will not work.
    /// 1) the fromController must be embedded in a navigation controller
    /// 2) the fromController must be at the top of the navigation stack preceding the event
    /// 3) the toController must be at the top of the navigation stack following the event
    /// - Parameter fromController: the controller at the top of the navigation stack preceding the event
    /// - Parameter toController: the controller at the top of the navigation stack following the event
    /// - Parameter event: the event which triggers the pop
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear and viewWillDisappear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear and viewDidDisappear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    /// - Parameter failTest: the side effect of test failure
    func assertPopped<From: UIViewController, To: UIViewController>(
        from fromController: From,
        to toController: To,
        when event: () -> Void,
        timeout: TimeInterval? = nil,
        onViewWillAppear: @escaping (From, To) -> Void = { _, _ in },
        onViewDidAppear: @escaping (From, To) -> Void = { _, _ in },
        file: StaticString = #file,
        line: UInt = #line,
        failTest: FailTest = log
    ) throws {
        
        guard let nav = fromController.navigationController else {
            let failedTest = FailedTest(error: NavigationPresentationError.noNavigationEmbedding(target: fromController),
                                        file: file,
                                        line: line)
            throw failTest(failedTest)
        }
        guard nav.viewControllers.suffix(1) == [fromController] else {
            let failedTest = FailedTest(error: NavigationPresentationError.unexpectedTopPrecedingEvent(expected: fromController, navigationController: nav),
                                        file: file,
                                        line: line)
            throw failTest(failedTest)
        }
        
        _ = try assertControllerEvent(
            from: fromController,
            to: { toController },
            when: event,
            timeout: timeout,
            onViewDidLoad: { _, _ in },
            onViewWillAppear: onViewWillAppear,
            onViewDidAppear: onViewDidAppear,
            file: file,
            line: line
        )
        
        guard nav.viewControllers.suffix(1) == [toController] else {
            let failedTest = FailedTest(error: NavigationPresentationError.unexpectedTopFollowingEvent(expected: toController, navigationController: nav),
                                        file: file,
                                        line: line)
            throw failTest(failedTest)
        }
        
    }
    
}
