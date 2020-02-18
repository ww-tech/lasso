//
//===----------------------------------------------------------------------===//
//
//  ControllerLifecycle.swift
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
//===----------------------------------------------------------------------===//
//

import XCTest

// swiftlint:disable opening_brace

extension XCTestCase {
    
    /// Generalized utility for controller lifecycle hooks with respect to view controller hierarchy events.
    /// No guarantees are made regarding how lifecycle hooks will be called.
    /// This utility should only be used where a more specific utility is not available.
    /// - Parameter fromController: the foremost controller preceding the event
    /// - Parameter resolveTarget: how to 'get' the target following the event
    /// - Parameter event: triggers the view controller hierarchy side effects
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear and viewWillDisappear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear and viewDidDisappear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    public func assertControllerEvent<From: UIViewController, To: UIViewController>(
        from fromController: From,
        to resolveTarget: () throws -> UIViewController?,
        when event: () -> Void,
        timeout: TimeInterval = 1,
        onViewDidLoad: (From, To) -> Void = { _, _ in },
        onViewWillAppear: @escaping (From, To) -> Void = { _, _ in },
        onViewDidAppear: @escaping (From, To) -> Void = { _, _ in },
        file: StaticString = #file,
        line: UInt = #line) throws -> To
    {
        
        event()
        
        let _toController = try resolveTarget()
        let toController: To = try typeCast(_toController, file: file, line: line)
        
        _ = toController.view
        onViewDidLoad(fromController, toController)
        
        let mainQueueExhaustion = expectMainQueueExhaustion()
        wait(for: [mainQueueExhaustion], timeout: timeout)
        onViewWillAppear(fromController, toController)
        
        if let transitionCompletion = expectTransitionCompletion(toController) {
            wait(for: [transitionCompletion], timeout: timeout)
        }
        onViewDidAppear(fromController, toController)
        
        return toController
    }
    
    /// Generalized utility for controller lifecycle hooks with respect to view controller hierarchy events.
    /// No guarantees are made regarding how lifecycle hooks will be called.
    /// This utility should only be used where a more specific utility is not available.
    /// - Parameter resolveTarget: how to 'get' the target following the event
    /// - Parameter event: triggers the view controller hierarchy side effects
    /// - Parameter timeout: maximum time allowance for the event
    /// - Parameter onViewDidLoad: hook corresponding to viewDidLoad
    /// - Parameter onViewWillAppear: hook corresponding to viewWillAppear
    /// - Parameter onViewDidAppear: hook corresponding to viewDidAppear
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    public func assertControllerEvent<To: UIViewController>(
        to resolveTarget: () throws -> UIViewController?,
        when event: () -> Void,
        timeout: TimeInterval = 1,
        onViewDidLoad: (To) -> Void = { _ in },
        onViewWillAppear: @escaping (To) -> Void = { _ in },
        onViewDidAppear: @escaping (To) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line) throws -> To
    {

        event()

        let _toController = try resolveTarget()
        let toController: To = try typeCast(_toController, file: file, line: line)

        _ = toController.view
        onViewDidLoad(toController)

        let mainQueueExhaustion = expectMainQueueExhaustion()
        wait(for: [mainQueueExhaustion], timeout: timeout)
        onViewWillAppear(toController)

        if let transitionCompletion = expectTransitionCompletion(toController) {
            wait(for: [transitionCompletion], timeout: timeout)
        }
        onViewDidAppear(toController)

        return toController
    }
    
    /// Wait for execution of all items enqueued on the main queue and completion of any view controller hierarchy
    /// transition. While no guarantees are made regarding lifecycle, it is expected that all pending controller lifecycle events
    /// have fired following this call.
    /// - Parameter window: the parent window of the target controllers
    /// - Parameter timeout: maximum time allowance for the events
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    public func waitForEvents(in window: UIWindow, timeout: TimeInterval = 1, file: StaticString = #file, line: UInt = #line) {
        let mainQueueExhaustion = expectMainQueueExhaustion()
        let transitionCompletion = expectTransitionCompletion(in: window)
        let expectations = [mainQueueExhaustion, transitionCompletion].compactMap({ $0 })
        wait(for: expectations, timeout: timeout)
    }
    
    internal func expectMainQueueExhaustion() -> XCTestExpectation {
        let exhaustion = expectation(description: "main queue exhaustion")
        DispatchQueue.main.async {
            exhaustion.fulfill()
        }
        return exhaustion
    }
    
    internal func expectTransitionCompletion(_ controller: UIViewController) -> XCTestExpectation? {
        if let transitionCoordinator = modallyForemostController(on: controller).transitionCoordinator {
            let transitionComplete = expectation(description: "controller transition complete")
            transitionCoordinator.animate(alongsideTransition: nil, completion: { _ in
                transitionComplete.fulfill()
            })
            return transitionComplete
        }
        else {
            return nil
        }
    }
    
    internal func expectTransitionCompletion(in window: UIWindow) -> XCTestExpectation? {
        guard let root = window.rootViewController else { return nil }
        return expectTransitionCompletion(root)
    }
    
    internal func modallyForemostController(on controller: UIViewController) -> UIViewController {
        var foremost = controller
        while let presented = foremost.presentedViewController {
            foremost = presented
        }
        return foremost
    }
    
}
