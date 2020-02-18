//
//===----------------------------------------------------------------------===//
//
//  ModalTestingTests+AnyModalPresentationStyle.swift
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

class ModalTestingTestsAnyModalPresentationStyle: XCTestCase {
    
    private func testSupportedStyles(_ test: (UIModalPresentationStyle) throws -> Void) throws {
        let styles: [UIModalPresentationStyle] = [.pageSheet, .fullScreen]
        try styles.forEach(test)
    }
    
    // MARK: - Presentation

    func test_Animated_Presentation() throws {
        
        let test = { (style: UIModalPresentationStyle) throws in
            // given
            let window = UIWindow()
            window.makeKeyAndVisible()
            let vc0 = LifeCycleController()
            let vc1 = LifeCycleController()
            vc1.modalPresentationStyle = style
            window.rootViewController = vc0
            self.waitForEvents(in: window)
            vc0.lifeCycleEvents = []
            vc1.lifeCycleEvents = []
            
            // when / then
            let result: LifeCycleController = try self.assertPresentation(
                on: vc0,
                when: { vc0.present(vc1, animated: true, completion: nil) },
                onViewDidLoad: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad])
            },
                onViewWillAppear: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear])
            },
                onViewDidAppear: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
            })
            XCTAssertTrue(result === vc1)
        }
        
        try testSupportedStyles(test)
    }
    
    func test_Presentation_WithPresentingEmbedding_Succeeds() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let nav0 = UINavigationController(rootViewController: vc0)
        let vc1 = UIViewController()
        window.rootViewController = nav0
        waitForEvents(in: window)
        
        // when / then
        let result: UIViewController = try self.assertPresentation(
            on: vc0,
            when: { vc0.present(vc1, animated: true, completion: nil) }
        )
        XCTAssertTrue(result === vc1)
    }
    
    func test_Presentation_WithModalStackLength3_Succeeds() throws {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let nav0 = UINavigationController(rootViewController: vc0)
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        window.rootViewController = nav0
        waitForEvents(in: window)
        nav0.present(vc1, animated: false, completion: nil)
        waitForEvents(in: window)
        
        // when / then
        let result: UIViewController = try self.assertPresentation(
            on: vc1,
            when: { vc1.present(vc2, animated: false, completion: nil) }
        )
        XCTAssertTrue(result === vc2)
    }
    
    // No guarantees are made with respect to viewWillAppear for unanimated presentations. It
    // does not make sense to hook into viewWillAppear b/c it is conceptually irrelevant - when
    // there is no animation, appearance happens all at once and there is no difference between 'will'
    // and 'did' appear.  'did' is the only appropriate hook here.
    func test_NotAnimated_Presentation() throws {
        
        let test = { (style: UIModalPresentationStyle) throws in
            // given
            let window = UIWindow()
            window.makeKeyAndVisible()
            let vc0 = LifeCycleController()
            let vc1 = LifeCycleController()
            vc1.modalPresentationStyle = style
            window.rootViewController = vc0
            self.waitForEvents(in: window)
            vc0.lifeCycleEvents = []
            vc1.lifeCycleEvents = []
            
            // when / then
            let result: LifeCycleController = try self.assertPresentation(
                on: vc0,
                when: { vc0.present(vc1, animated: false, completion: nil) },
                onViewDidLoad: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad])
            },
                onViewDidAppear: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
            })
            XCTAssertTrue(result === vc1)
        }
        
        try testSupportedStyles(test)
    }
    
    func test_NoPresentationOnWhen_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: { try _ = assertPresentation(on: vc0, when: { }, failTest: silent) },
            eval: {
                switch $0 {
                case ModalPresentationError.noPresentationOccurred: ()
                default: unexpectedErrorType()
                }
        })
    }
    
    func test_PresentingWrongType_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                let _: UINavigationController = try assertPresentation(
                    on: vc0,
                    when: { vc0.present(vc1, animated: false, completion: nil) },
                    failTest: silent
                )
        },
            eval: {
                switch $0 {
                case ModalPresentationTypeError<UINavigationController>.unexpectedPresentedTypeFollowingEvent(realized: let realized):
                    XCTAssertTrue(realized === vc1)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_PresentingNotModallyForemostPrecedingPresentationEvent_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.present(vc1, animated: false, completion: nil)
        waitForEvents(in: window)

        // when / then
        assertThrowsError(
            expr: { let _: UIViewController = try assertPresentation(on: vc0, when: { }, failTest: silent) },
            eval: {
                switch $0 {
                case ModalPresentationError.unexpectedModallyForemostPrecedingEvent(expected: let expected, realized: let realized):
                    XCTAssertTrue(expected === vc0)
                    XCTAssertTrue(realized === vc1)

                default:
                    unexpectedErrorType()
                }
        })
    }

    func test_PresentedNotModallyForemostFollowingPresentationEvent_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)

        // when / then
        assertThrowsError(
            expr: {
                let _: UIViewController = try assertPresentation(
                    on: vc0,
                    when: {
                        vc0.present(vc1, animated: false, completion: nil)
                        waitForEvents(in: window)
                        vc1.present(vc2, animated: false, completion: nil)
                        waitForEvents(in: window)
                },
                    failTest: silent)
        },
            eval: {
                switch $0 {
                case ModalPresentationError.unexpectedModallyForemostFollowingEvent(expected: let expected, realized: let realized):
                    XCTAssertTrue(expected == [vc0, vc1])
                    XCTAssertTrue(realized == [vc1, vc2])

                default:
                    unexpectedErrorType()
                }
        })
    }
    
    // MARK: - Dismissal
    
    func test_Animated_Dismissal() throws {
        
        let test = { (style: UIModalPresentationStyle) throws in
            // given
            let window = UIWindow()
            window.makeKeyAndVisible()
            let vc0 = LifeCycleController()
            let vc1 = LifeCycleController()
            vc1.modalPresentationStyle = style
            window.rootViewController = vc0
            self.waitForEvents(in: window)
            vc0.present(vc1, animated: true, completion: nil)
            self.waitForEvents(in: window)
            vc0.lifeCycleEvents = []
            vc1.lifeCycleEvents = []
            
            // when / then
            try self.assertDismissal(
                from: vc1,
                to: vc0,
                when: { vc0.dismiss(animated: true, completion: nil) },
                onViewWillAppear: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear])
            },
                onViewDidAppear: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
            })
        }
        
        try testSupportedStyles(test)
    }
    
    func test_NotAnimated_Dismissal() throws {
        
        let test = { (style: UIModalPresentationStyle) throws in
            // given
            let window = UIWindow()
            window.makeKeyAndVisible()
            let vc0 = LifeCycleController()
            let vc1 = LifeCycleController()
            vc1.modalPresentationStyle = style
            window.rootViewController = vc0
            self.waitForEvents(in: window)
            vc0.present(vc1, animated: true, completion: nil)
            self.waitForEvents(in: window)
            vc0.lifeCycleEvents = []
            vc1.lifeCycleEvents = []
            
            // when / then
            try self.assertDismissal(
                from: vc1,
                to: vc0,
                when: { vc0.dismiss(animated: false, completion: nil) },
                onViewDidAppear: { presented in
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
            })
        }
        
        try testSupportedStyles(test)
    }
    
    func test_PresentedNotForemostPrecedingDismissalEvent_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.present(vc1, animated: false, completion: nil)
        waitForEvents(in: window)
        vc1.present(vc2, animated: false, completion: nil)
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: { try _ = assertDismissal(from: vc1, to: vc0, when: { }, failTest: silent) },
            eval: {
                switch $0 {
                    
                case ModalPresentationError.unexpectedModallyForemostPrecedingEvent(expected: let expected, realized: let realized):
                    XCTAssertTrue(expected === vc1)
                    XCTAssertTrue(realized === vc2)
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_EmptyDismissalEvent_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.present(vc1, animated: false, completion: nil)
        waitForEvents(in: window)
        vc1.present(vc2, animated: false, completion: nil)
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try _ = assertDismissal(
                    from: vc2,
                    to: vc0,
                    when: { },
                    failTest: silent
                )
        },
            eval: {
                switch $0 {
                    
                case ModalPresentationError.noDismissalOccurred:
                    ()
                    
                default:
                    unexpectedErrorType()
                }
        })
    }
    
    func test_PresentingNotForemostFollowingDismissalEvent_Fails() {
        // given
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc0 = UIViewController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        window.rootViewController = vc0
        waitForEvents(in: window)
        vc0.present(vc1, animated: false, completion: nil)
        waitForEvents(in: window)
        vc1.present(vc2, animated: false, completion: nil)
        waitForEvents(in: window)
        
        // when / then
        assertThrowsError(
            expr: {
                try _ = assertDismissal(
                    from: vc2,
                    to: vc0,
                    when: { vc1.dismiss(animated: false, completion: nil) },
                    failTest: silent
                )
        },
            eval: {
                switch $0 {
                    
                case ModalPresentationError.unexpectedModallyForemostFollowingEvent(expected: let expected, realized: let realized):
                    XCTAssertTrue(expected == [vc0])
                    XCTAssertTrue(realized == [vc1])
                    
                default:
                    unexpectedErrorType()
                }
        })
    }

}
