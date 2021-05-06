//
// ==----------------------------------------------------------------------== //
//
//  NavigationTestingTests.swift
//
//  Created by Trevor Beasty on 8/8/19.
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
import UIKit
@testable import LassoTestUtilities

// swiftlint:disable file_length

class NavigationTestingTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(true)
    }
    
    // MARK: - Success
    
    // assertPushed
    
    func test_AssertPushed_Animated() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []
        
        // when / then
        let result: LifeCycleController = try assertPushed(
            after: vc0,
            when: { nav.pushViewController(vc1, animated: true) },
            onViewDidLoad: { previous, pushed in
                XCTAssertTrue(previous === vc0)
                XCTAssertTrue(pushed === vc1)
                XCTAssertEqual(pushed.lifeCycleEvents, [.viewDidLoad])
                XCTAssertEqual(previous.lifeCycleEvents, [])
        },
            onViewWillAppear: { previous, pushed in
                XCTAssertTrue(previous === vc0)
                XCTAssertTrue(pushed === vc1)
                XCTAssertEqual(pushed.lifeCycleEvents, [.viewDidLoad, .viewWillAppear])
                XCTAssertEqual(previous.lifeCycleEvents, [.viewWillDisappear])
        },
            onViewDidAppear: { previous, pushed in
                XCTAssertTrue(previous === vc0)
                XCTAssertTrue(pushed === vc1)
                XCTAssertEqual(pushed.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                XCTAssertEqual(previous.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        })
        XCTAssertTrue(result === vc1)
    }
    
    func test_AssertPushed_NotAnimated() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []
        
        // when / then
        let result: LifeCycleController = try assertPushed(
            after: vc0,
            when: { nav.pushViewController(vc1, animated: false) },
            onViewDidLoad: { previous, pushed in
                XCTAssertTrue(previous === vc0)
                XCTAssertTrue(pushed === vc1)
                XCTAssertEqual(pushed.lifeCycleEvents, [.viewDidLoad])
                XCTAssertEqual(previous.lifeCycleEvents, [])
        },
            onViewWillAppear: { previous, pushed in
                XCTAssertTrue(previous === vc0)
                XCTAssertTrue(pushed === vc1)
                XCTAssertEqual(pushed.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                XCTAssertEqual(previous.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        },
            onViewDidAppear: { previous, pushed in
                XCTAssertTrue(previous === vc0)
                XCTAssertTrue(pushed === vc1)
                XCTAssertEqual(pushed.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                XCTAssertEqual(previous.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        })
        XCTAssertTrue(result === vc1)
    }
    
    // assertRoot
    
    func test_AssertRoot() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc = LifeCycleController()
        let nav = UINavigationController()
        window.rootViewController = nav
        waitForEvents(in: window)
        vc.lifeCycleEvents = []
        
        // when / then
        let result: LifeCycleController = try assertRoot(
            of: nav,
            when: { nav.viewControllers = [vc] },
            onViewDidLoad: { root in
                XCTAssertTrue(root === vc)
                XCTAssertEqual(root.lifeCycleEvents, [.viewDidLoad])
        },
            onViewWillAppear: { root in
                XCTAssertTrue(root === vc)
                XCTAssertEqual(root.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
        },
            onViewDidAppear: { root in
                XCTAssertTrue(root === vc)
                XCTAssertEqual(root.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
        })
        XCTAssertTrue(result === vc)
    }
    
    // assertPopped
    
    func test_AssertPopped_Animated() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        nav.pushViewController(vc1, animated: true)
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []
        
        // when / then
        try assertPopped(
            from: vc1,
            to: vc0,
            when: { nav.popViewController(animated: true) },
            onViewWillAppear: { from, to in
                XCTAssertTrue(to === vc0)
                XCTAssertTrue(from === vc1)
                XCTAssertEqual(to.lifeCycleEvents, [.viewWillAppear])
                XCTAssertEqual(from.lifeCycleEvents, [.viewWillDisappear])
        },
            onViewDidAppear: { from, to in
                XCTAssertTrue(to === vc0)
                XCTAssertTrue(from === vc1)
                XCTAssertEqual(to.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                XCTAssertEqual(from.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        })
    }
    
    func test_AssertPopped_NotAnimated() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        nav.pushViewController(vc1, animated: true)
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []
        
        // when / then
        try assertPopped(
            from: vc1,
            to: vc0,
            when: { nav.popViewController(animated: false) },
            onViewWillAppear: { from, to in
                XCTAssertTrue(to === vc0)
                XCTAssertTrue(from === vc1)
                XCTAssertEqual(to.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                XCTAssertEqual(from.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        },
            onViewDidAppear: { from, to in
                XCTAssertTrue(to === vc0)
                XCTAssertTrue(from === vc1)
                XCTAssertEqual(to.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                XCTAssertEqual(from.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        })
    }
    
    // MARK: - Failure
    
    // push
    
    func test_PushingWrongType_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)

        // when / then
        assertThrowsError(
            expr: {
                let _: UITabBarController = try assertPushed(after: vc0, when: { nav.pushViewController(vc1, animated: false) }, failTest: silent)
        },
            eval: {
                switch $0 {

                case NavigationPresentationTypeError<UITabBarController>.unexpectedPushedType(realized: let realized):
                    XCTAssertTrue(realized === vc1)

                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_NoNavEmbeddingPrecedingPush_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try _ = assertPushed(after: vc0, when: { }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.noNavigationEmbedding(target: let target):
                    XCTAssertTrue(target === vc0)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_PreviousNotTopPrecedingPush_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        nav.pushViewController(vc1, animated: false)
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try _ = assertPushed(after: vc0, when: { }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.unexpectedTopPrecedingEvent(expected: let expected, navigationController: let _nav):
                    XCTAssertTrue(expected === vc0)
                    XCTAssertTrue(_nav === nav)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_EmptyStackFollowingPush_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try _ = assertPushed(after: vc0, when: { nav.viewControllers = [] }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.unexpectedEmptyStackFollowingEvent(navigationController: let _nav):
                    XCTAssertTrue(_nav === nav)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }

    func test_BadTopStackFollowingPush_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)

        // when / then
        assertThrowsError(
            expr: {
                try _ = assertPushed(
                    after: vc0,
                    when: {
                        nav.pushViewController(vc1, animated: false)
                        waitForEvents(in: window)
                        nav.pushViewController(vc2, animated: false)
                        waitForEvents(in: window)
                },
                    failTest: silent)
        },
            eval: {
                switch $0 {

                case NavigationPresentationError.unexpectedTopStackFollowingEvent(expected: let expected, navigationController: let _nav):
                    XCTAssertEqual(expected, [vc0, vc2])
                    XCTAssertTrue(_nav === nav)

                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_NoPush_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)

        // when / then
        assertThrowsError(
            expr: {
                try _ = assertPushed(
                    after: vc0,
                    when: { () },
                    failTest: silent)
        },
            eval: {
                switch $0 {

                case NavigationPresentationError.noPushOccurred(previous: let previous):
                    XCTAssertEqual(previous, vc0)

                default:
                    unexpectedErrorType()
                }
        })
    }
    
    // root
    
    func test_NoNewRootReplacingOld_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)

        // when / then
        assertThrowsError(
            expr: {
                let _: UITabBarController = try assertRoot(of: nav, when: { }, failTest: silent)
        },
            eval: {
                switch $0 {

                case NavigationPresentationError.oldRootRemainsFollowingRootEvent(oldRoot: let oldRoot, navigationController: let _nav):
                    XCTAssertTrue(oldRoot === vc0)
                    XCTAssertTrue(_nav === nav)

                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_RootingWrongType_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)

        // when / then
        assertThrowsError(
            expr: {
                let _: UITabBarController = try assertRoot(of: nav, when: { nav.viewControllers = [vc1] }, failTest: silent)
        },
            eval: {
                switch $0 {

                case NavigationPresentationTypeError<UITabBarController>.unexpectedRootType(realized: let realized):
                    XCTAssertTrue(realized === vc1)

                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_EmptyStackFollowingRootEvent_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let nav = UINavigationController()
        window.rootViewController = nav
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try _ = assertRoot(of: nav, when: { }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.unexpectedStackFollowingRootEvent(navigationController: let _nav):
                    XCTAssertTrue(_nav === nav)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_ManyInStackFollowingRootEvent_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try _ = assertRoot(of: nav, when: { nav.pushViewController(vc1, animated: false) }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.unexpectedStackFollowingRootEvent(navigationController: let _nav):
                    XCTAssertTrue(_nav === nav)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    // pop
    
    func test_NoNavigationEmbeddingPrecedingPop_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try assertPopped(from: vc0, to: UIViewController(), when: { }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.noNavigationEmbedding(target: let target):
                    XCTAssertTrue(target === vc0)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_FromControllerNotTopPrecedingPop_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        nav.pushViewController(UIViewController(), animated: false)
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try assertPopped(from: vc0, to: UIViewController(), when: { }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.unexpectedTopPrecedingEvent(expected: let expected, navigationController: let _nav):
                    XCTAssertTrue(expected === vc0)
                    XCTAssertTrue(_nav === nav)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_ToControllerNotTopFollowingPop_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let nav = UINavigationController(rootViewController: vc0)
        window.rootViewController = nav
        waitForEvents(in: window)
        nav.pushViewController(vc1, animated: false)
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try assertPopped(from: vc1, to: vc0, when: { }, failTest: silent)
        },
            eval: {
                switch $0 {
                    
                case NavigationPresentationError.unexpectedTopFollowingEvent(expected: let expected, navigationController: let _nav):
                    XCTAssertTrue(expected === vc0)
                    XCTAssertTrue(_nav === nav)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }

}
