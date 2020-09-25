//
//===----------------------------------------------------------------------===//
//
//  ModalTesting.swift
//
//  Created by Trevor Beasty on 8/6/19.
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

import XCTest

// swiftlint:disable opening_brace function_parameter_count

extension XCTestCase {
    
    /// Assert that the event will result in a modal presentation on the presenting controller.
    /// The only lifecycle hooks provided are those which are common across all modalPresentationStyles
    /// and iOS versions - namely, all lifecycle events for the presented controller.
    /// CRITICAL: Controllers must be descendants of a UIWindow which is 'key and visible', otherwise,
    /// lifecycle hooks will not work.
    /// 1) presenting must be modally foremost preceding event
    /// 2) presenting and presented must be modally foremost following event
    /// - Parameter presenting: the base of the presentation
    /// - Parameter event: the event which triggers the presentation
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear and viewWillDisappear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear and viewDidDisappear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    /// - Parameter failTest: the side effect of test failure
    public func assertPresentation<Presenting: UIViewController, Presented: UIViewController>(
        on presenting: Presenting,
        when event: () -> Void,
        timeout: TimeInterval = defaultLassoAssertionTimeout,
        onViewDidLoad: (Presented) -> Void = { _ in },
        onViewWillAppear: @escaping (Presented) -> Void = { _ in },
        onViewDidAppear: @escaping (Presented) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line,
        failTest: FailTest = log,
        verbose: Bool = true) throws -> Presented
    {
        return try _assertPresentation(
            on: presenting,
            when: event,
            timeout: timeout,
            onViewDidLoad: { onViewDidLoad($1) },
            onViewWillAppear: { onViewWillAppear($1) },
            onViewDidAppear: { onViewDidAppear($1) },
            file: file,
            line: line,
            failTest: failTest,
            verbose: verbose
        )
    }
    
    /// Assert that the event will result in a modal dismissal from the presented to the presenting controller.
    /// The only lifecycle hooks provided are those which are common across all modalPresentationStyles
    /// and iOS versions - namely, all lifecycle events for the presented controller.
    /// CRITICAL: Controllers must be descendants of a UIWindow which is 'key and visible', otherwise,
    /// lifecycle hooks will not work.
    /// 1) presented must be modally foremost preceding event
    /// 2) presenting must be modally foremost following event
    /// - Parameter presented: the modally foremost controller preceding the event
    /// - Parameter presenting: the modally foremost controller following the event
    /// - Parameter event: the event which triggers the dismissal
    /// - Parameter timeout: maximum time allowance for the presentation
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear and viewWillDisappear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear and viewDidDisappear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    /// - Parameter failTest: the side effect of test failure
    public func assertDismissal<Presenting: UIViewController, Presented: UIViewController>(
        from presented: Presented,
        to presenting: Presenting,
        when event: () -> Void,
        timeout: TimeInterval = defaultLassoAssertionTimeout,
        onViewWillAppear: @escaping (Presented) -> Void = { _ in },
        onViewDidAppear: @escaping (Presented) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line,
        failTest: FailTest = log) throws
    {
        try _assertDismissal(
            from: presented,
            to: presenting,
            when: event,
            timeout: timeout,
            onViewWillAppear: { presented, _ in
                onViewWillAppear(presented)
        },
            onViewDidAppear: { presented, _ in
                onViewDidAppear(presented)
        },
            file: file,
            line: line,
            failTest: failTest
        )
    }

    /// Assert that the event will result in a modal presentation on the presenting controller with a fullScreen
    /// modalPresentationStyle. The presenting and presented controllers receive the full set of lifecycle hooks.
    /// CRITICAL: Controllers must be descendants of a UIWindow which is 'key and visible', otherwise,
    /// lifecycle hooks will not work.
    /// 1) presenting must be modally foremost preceding event
    /// 2) presenting and presented must be modally foremost following event
    /// 3) presented must have a fullScreen modalPresentationStyle
    /// - Parameter presenting: the base of the presentation
    /// - Parameter event: the event which triggers the presentation
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear and viewWillDisappear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear and viewDidDisappear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    /// - Parameter failTest: the side effect of test failure
    public func assertFullScreenPresentation<Presenting: UIViewController, Presented: UIViewController>(
        on presenting: Presenting,
        when event: () -> Void,
        timeout: TimeInterval = defaultLassoAssertionTimeout,
        onViewDidLoad: (Presenting, Presented) -> Void = { _, _ in },
        onViewWillAppear: @escaping (Presenting, Presented) -> Void = { _, _ in },
        onViewDidAppear: @escaping (Presenting, Presented) -> Void = { _, _ in },
        file: StaticString = #file,
        line: UInt = #line,
        failTest: FailTest = log,
        verbose: Bool = true) throws -> Presented
    {
        let presented = try _assertPresentation(
            on: presenting,
            when: event,
            timeout: timeout,
            onViewDidLoad: onViewDidLoad,
            onViewWillAppear: onViewWillAppear,
            onViewDidAppear: onViewDidAppear,
            file: file,
            line: line,
            failTest: failTest,
            verbose: verbose
        )
        
        guard presented.modalPresentationStyle == .fullScreen else {
            let failedTest = FailedTest(error: ModalPresentationError.unexpectedModalPresentationStyle(expected: .fullScreen, realized: presented.modalPresentationStyle),
                                        file: file,
                                        line: line,
                                        verbose: verbose)
            throw failTest(failedTest)
        }
        
        return presented
    }
    
    /// Assert that the event will result in a modal dismissal from the presented to the presenting controller with a fullScreen
    /// modalPresentationStyle. The presenting and presented controllers receive the full set of lifecycle hooks.
    /// CRITICAL: Controllers must be descendants of a UIWindow which is 'key and visible', otherwise,
    /// lifecycle hooks will not work.
    /// 1) presented must be modally foremost preceding event
    /// 2) presenting must be modally foremost following event
    /// 3) presented must have a fullScreen modalPresentationStyle
    /// - Parameter presented: the modally foremost controller preceding the event
    /// - Parameter presenting: the modally foremost controller following the event
    /// - Parameter event: the event which triggers the dismissal
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear and viewWillDisappear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear and viewDidDisappear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    /// - Parameter failTest: the side effect of test failure
    public func assertFullScreenDismissal<Presenting: UIViewController, Presented: UIViewController>(
        from presented: Presented,
        to presenting: Presenting,
        when event: () -> Void,
        timeout: TimeInterval = defaultLassoAssertionTimeout,
        onViewWillAppear: @escaping (Presented, Presenting) -> Void = { _, _ in },
        onViewDidAppear: @escaping (Presented, Presenting) -> Void = { _, _ in },
        file: StaticString = #file,
        line: UInt = #line,
        failTest: FailTest = log) throws
    {
        guard presented.modalPresentationStyle == .fullScreen else {
            let failedTest = FailedTest(error: ModalPresentationError.unexpectedModalPresentationStyle(expected: .fullScreen, realized: presented.modalPresentationStyle),
                                        file: file,
                                        line: line)
            throw failTest(failedTest)
        }
        
        try _assertDismissal(
            from: presented,
            to: presenting,
            when: event,
            timeout: timeout,
            onViewWillAppear: onViewWillAppear,
            onViewDidAppear: onViewDidAppear,
            file: file,
            line: line,
            failTest: failTest
        )
    }
    
    private func _assertPresentation<Presenting: UIViewController, Presented: UIViewController>(
        on presenting: Presenting,
        when event: () -> Void,
        timeout: TimeInterval,
        onViewDidLoad: (Presenting, Presented) -> Void,
        onViewWillAppear: @escaping (Presenting, Presented) -> Void,
        onViewDidAppear: @escaping (Presenting, Presented) -> Void,
        file: StaticString,
        line: UInt,
        failTest: FailTest,
        verbose: Bool) throws -> Presented
    {
        
        let modallyForemost = modallyForemostController(on: presenting)
        guard modallyForemost === presenting else {
            let failedTest = FailedTest(error: ModalPresentationError.unexpectedModallyForemostPrecedingEvent(expected: presenting, realized: modallyForemost),
                                        file: file,
                                        line: line,
                                        verbose: verbose)
            throw failTest(failedTest)
        }
        
        do {
            let presented: Presented = try assertControllerEvent(
                from: presenting,
                to: { presenting.presentedViewController },
                when: event,
                timeout: timeout,
                onViewDidLoad: onViewDidLoad,
                onViewWillAppear: onViewWillAppear,
                onViewDidAppear: onViewDidAppear
            )
            
            let modallyForemost = modallyForemostController(on: presented)
            let followingStack = modalStack(preceding: modallyForemost)
            guard followingStack.suffix(2) == [topParent(of: presenting), presented] else {
                throw ModalPresentationError.unexpectedModallyForemostFollowingEvent(expected: [topParent(of: presenting), presented], realized: followingStack.suffix(2))
            }
            
            return presented
        }
        catch let error {
            switch error {
                
            case TypeCastError<UIViewController, Presented>.failedToResolveInstance:
                let failedTest = FailedTest(error: ModalPresentationError.noPresentationOccurred,
                                            file: file,
                                            line: line,
                                            verbose: verbose)
                throw failTest(failedTest)
                
            case TypeCastError<UIViewController, Presented>.unexpectedInstanceType(instance: let instance):
                let failedTest = FailedTest(error: ModalPresentationTypeError<Presented>.unexpectedPresentedTypeFollowingEvent(realized: instance),
                                            file: file,
                                            line: line,
                                            verbose: verbose)
                throw failTest(failedTest)
                
            default:
                guard let lassoError = error as? LassoError else {
                    fatalError("should never execute")
                }
                let failedTest = FailedTest(error: lassoError,
                                            file: file,
                                            line: line,
                                            verbose: verbose)
                throw failTest(failedTest)
                
            }
        }
        
    }
    
    private func _assertDismissal<Presenting: UIViewController, Presented: UIViewController>(
        from presented: Presented,
        to presenting: Presenting,
        when event: () -> Void,
        timeout: TimeInterval,
        onViewWillAppear: @escaping (Presented, Presenting) -> Void,
        onViewDidAppear: @escaping (Presented, Presenting) -> Void,
        file: StaticString,
        line: UInt,
        failTest: FailTest) throws
    {
        
        let modallyForemostPreceding = modallyForemostController(on: presented)
        guard modallyForemostPreceding === presented else {
            let failedTest = FailedTest(error: ModalPresentationError.unexpectedModallyForemostPrecedingEvent(expected: presented, realized: modallyForemostPreceding),
                                        file: file,
                                        line: line)
            throw failTest(failedTest)
        }
        let precedingStack = modalStack(preceding: modallyForemostPreceding)
        
        _ = try assertControllerEvent(
            from: presented,
            to: { presenting },
            when: event,
            timeout: timeout,
            onViewDidLoad: { _, _ in },
            onViewWillAppear: onViewWillAppear,
            onViewDidAppear: onViewDidAppear,
            file: file,
            line: line
        )
        
        let modallyForemostFollowing = modallyForemostController(on: presenting)
        let followingStack = modalStack(preceding: modallyForemostFollowing)
        guard !(followingStack == precedingStack) else {
            let failedTest = FailedTest(error: ModalPresentationError.noDismissalOccurred,
                                        file: file,
                                        line: line)
            throw failTest(failedTest)
        }
        guard modallyForemostFollowing === presenting else {
            let failedTest = FailedTest(error: ModalPresentationError.unexpectedModallyForemostFollowingEvent(expected: [presenting], realized: followingStack.suffix(1)),
                                        file: file,
                                        line: line)
            throw failTest(failedTest)
        }
    }
    
}

private func modalStack(preceding controller: UIViewController) -> [UIViewController] {
    var stack = [UIViewController]()
    var last: UIViewController? = controller
    while let _last = last {
        stack.append(_last)
        last = _last.presentingViewController
    }
    return stack.reversed()
}

private func topParent(of controller: UIViewController) -> UIViewController {
    var top = controller
    while let parent = top.parent { top = parent }
    return top
}
