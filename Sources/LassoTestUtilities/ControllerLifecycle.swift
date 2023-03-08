//
// ==----------------------------------------------------------------------== //
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
// ==----------------------------------------------------------------------== //
//

import XCTest

// swiftlint:disable opening_brace

/// Allows for customization of the default `timeout` values used in
/// view controller life-cycle assertions (e.g., `assertRoot`, `assertPushed`, etc.)
///
/// By default all timeouts are one second.
///
/// Add `AssertionTimeoutOverride` conformance to your test case, and provide
/// a value for `defaultLassoAssertionTimeout` to use a custom timeout.
public protocol AssertionTimeoutOverride {
    var defaultLassoAssertionTimeout: TimeInterval { get }
}

extension XCTestCase {
    
    /// The effective timeout to use when waiting on the main queue.
    ///
    /// By default all timeouts are one second.
    ///
    /// Add `AssertionTimeoutOverride` conformance to your test case, and provide
    /// a value for `defaultLassoAssertionTimeout` to use a custom timeout.
    internal var lassoAssertionTimeout: TimeInterval {
        if let override = self as? AssertionTimeoutOverride {
            return override.defaultLassoAssertionTimeout
        }
        return 5
    }

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
        timeout: TimeInterval? = nil,
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
        
        try waitWithError(for: expectMainQueueExhaustion(), timeout: timeout)
        onViewWillAppear(fromController, toController)
        
        if let transitionCompletion = expectTransitionCompletion(toController) {
            try waitWithError(for: transitionCompletion, timeout: timeout)
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
        timeout: TimeInterval? = nil,
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

        try waitWithError(for: expectMainQueueExhaustion(), timeout: timeout)
        onViewWillAppear(toController)

        if let transitionCompletion = expectTransitionCompletion(toController) {
            try waitWithError(for: transitionCompletion, timeout: timeout)
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
    public func waitForEvents(
        in window: UIWindow,
        timeout: TimeInterval? = nil,
        file: StaticString = #file,
        line: UInt = #line)
    {
        let mainQueueExhaustion = expectMainQueueExhaustion()
        let transitionCompletion = expectTransitionCompletion(in: window)
        let expectations = [mainQueueExhaustion, transitionCompletion].compactMap({ $0 })
        wait(for: expectations, timeout: timeout ?? lassoAssertionTimeout)
    }
    
    /// Wait for execution of all items enqueued on the main queue and completion of any view controller hierarchy
    /// transition. While no guarantees are made regarding lifecycle, it is expected that all pending controller lifecycle events
    /// have fired following this call.
    /// - Parameter window: the parent window of the target controllers
    /// - Parameter timeout: maximum time allowance for the events
    public func waitForEventsWithError(
        in window: UIWindow,
        timeout: TimeInterval? = nil) throws
    {
        let mainQueueExhaustion = expectMainQueueExhaustion()
        let transitionCompletion = expectTransitionCompletion(in: window)
        let expectations = [mainQueueExhaustion, transitionCompletion].compactMap({ $0 })
        try waitWithError(for: expectations, timeout: timeout)
    }
    
    public enum WaitError: LassoError {
        case timedOut(String)
        case incorrectOrder(String)
        case invertedFulfillment(String)
        case interrupted(String)
        case unknown(String)
        
        public func message(verbose: Bool) -> String {
            switch self {
            case .timedOut(let message),
                 .incorrectOrder(let message),
                 .invertedFulfillment(let message),
                 .interrupted(let message),
                 .unknown(let message):
                return message
            }
        }
        
    }
    
    internal func waitWithError(for expectation: XCTestExpectation, timeout: TimeInterval? = nil) throws {
        try waitWithError(for: [expectation], timeout: timeout)
    }
    
    internal func waitWithError(for expectations: [XCTestExpectation], timeout: TimeInterval? = nil) throws {
        let timeout = timeout ?? lassoAssertionTimeout
        let waiter = XCTWaiter()
        let waitResult = waiter.wait(for: expectations, timeout: timeout)
        
        var description: String {
            return expectations.map({ "\"\($0)\"" }).joined(separator: ", ")
        }
        
        switch waitResult {
        case .completed: return
            
        case .timedOut: throw WaitError.timedOut("wait of \(timeout) seconds timed out: \(description)")
        case .incorrectOrder: throw WaitError.incorrectOrder("incorrect order for \(description)")
        case .invertedFulfillment: throw WaitError.invertedFulfillment("inverted fulfilment for \(description)")
        case .interrupted: throw WaitError.incorrectOrder("wait interrupted for \(description)")
        @unknown default: throw WaitError.unknown("\(waitResult) for \(description)")
        }
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
