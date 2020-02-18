//
//===----------------------------------------------------------------------===//
//
//  ModalTestingTests+FullScreen.swift
//
//  Created by Trevor Beasty on 8/30/19.
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
@testable import LassoTestUtilities

class ModalTestingTestsFullScreen: XCTestCase {
    
    // MARK: - Success

    func test_Animated_Presentation() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        vc1.modalPresentationStyle = .fullScreen
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []
        
        // when / then
        let _: UIViewController = try assertFullScreenPresentation(
            on: vc0,
            when: { vc0.present(vc1, animated: true, completion: nil) },
            onViewDidLoad: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad])
        },
            onViewWillAppear: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear])
        },
            onViewDidAppear: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
        })
    }
    
    func test_NotAnimated_Presentation() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        vc1.modalPresentationStyle = .fullScreen
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []

        // when / then
        let _: UIViewController = try assertFullScreenPresentation(
            on: vc0,
            when: { vc0.present(vc1, animated: false, completion: nil) },
            onViewDidLoad: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad])
        },
            // For non-animated modal presentations, viewWillAppear is not distinguishable from viewDidAppear.
            onViewWillAppear: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
        },
            onViewDidAppear: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
        })
    }
    
    // Tests should pass if assertPresentation is called where 'presenting' is a child of a navigation controller
    func test_Presentation_OnNavigationEmbeddedController() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let navigationController = UINavigationController(rootViewController: vc0)
        let vc1 = LifeCycleController()
        vc1.modalPresentationStyle = .fullScreen
        window.rootViewController = navigationController
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []
        
        // when / then
        let _: UIViewController = try assertFullScreenPresentation(
            on: vc0,
            when: { vc0.present(vc1, animated: true, completion: nil) },
            onViewDidLoad: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad])
        },
            onViewWillAppear: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear])
        },
            onViewDidAppear: { presenting, presented in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
        })
    }

    func test_Animated_Dismissal() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        vc1.modalPresentationStyle = .fullScreen
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.present(vc1, animated: true, completion: nil)
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []

        // when / then
        try assertFullScreenDismissal(
            from: vc1,
            to: vc0,
            when: { vc1.dismiss(animated: true, completion: nil) },
            onViewWillAppear: { presented, presenting in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear])
        },
            onViewDidAppear: { presented, presenting in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        })
    }

    func test_NotAnimated_Dismissal() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = LifeCycleController()
        let vc1 = LifeCycleController()
        vc1.modalPresentationStyle = .fullScreen
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.present(vc1, animated: true, completion: nil)
        waitForEvents(in: window)
        vc0.lifeCycleEvents = []
        vc1.lifeCycleEvents = []

        // when / then
        try assertFullScreenDismissal(
            from: vc1,
            to: vc0,
            when: { vc1.dismiss(animated: false, completion: nil) },
            // For non-animated modal dismissals, viewWillAppear is not distinguishable from viewDidAppear.
            onViewWillAppear: { presented, presenting in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        },
            onViewDidAppear: { presented, presenting in
                XCTAssertTrue(presenting === vc0)
                XCTAssertTrue(presented === vc1)
                XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
        })
    }
    
    // MARK: - Failure
    
    // TODO: pass locally but not on circle for <= Xcode 10.3. Likely due to system overrides for modalPresentationStyle
    // based on device 'size class'. There is no available api to configure this.
//    func test_PresentingWrongModalStyle_Fails() {
//        // given
//        let window = UIWindow()
//        window.makeKeyAndVisible()
//        let vc0 = UIViewController()
//        let vc1 = UIViewController()
//        vc1.modalPresentationStyle = .pageSheet
//        window.rootViewController = vc0
//        waitForEvents(in: window)
//
//        // when / then
//        assertThrowsError(
//            expr: {
//                try _ = assertFullScreenPresentation(on: vc0, when: { vc0.present(vc1, animated: false, completion: nil) }, failTest: silent)
//        },
//            eval: {
//                switch $0 {
//
//                case ModalPresentationError.unexpectedModalPresentationStyle(expected: let expected, realized: let realized):
//                    XCTAssertEqual(expected, .fullScreen)
//                    XCTAssertEqual(realized, .pageSheet)
//
//                default:
//                    unexpectedErrorType()
//                }
//        })
//    }
//
//    func test_DismissingWrongModalStyle_Fails() {
//        // given
//        let window = UIWindow()
//        window.makeKeyAndVisible()
//        let vc0 = UIViewController()
//        let vc1 = UIViewController()
//        vc1.modalPresentationStyle = .pageSheet
//        window.rootViewController = vc0
//        waitForEvents(in: window)
//        vc0.present(vc1, animated: false, completion: nil)
//        waitForEvents(in: window)
//
//        // when / then
//        assertThrowsError(
//            expr: {
//                try assertFullScreenDismissal(from: vc1, to: vc0, when: { vc1.dismiss(animated: false, completion: nil) }, failTest: silent)
//        },
//            eval: {
//                switch $0 {
//
//                case ModalPresentationError.unexpectedModalPresentationStyle(expected: let expected, realized: let realized):
//                    XCTAssertEqual(expected, .fullScreen)
//                    XCTAssertEqual(realized, .pageSheet)
//
//                default:
//                    unexpectedErrorType()
//                }
//        })
//    }

}
