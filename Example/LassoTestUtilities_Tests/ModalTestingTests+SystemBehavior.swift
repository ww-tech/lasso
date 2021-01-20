//
//===----------------------------------------------------------------------===//
//
//  ModalTestingTests+SystemBehavior.swift
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

class ModalTestingTestsSystemBehavior: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(true)
    }
    
    private func testSupportedStyles(_ test: (UIModalPresentationStyle) throws -> Void) throws {
        let styles: [UIModalPresentationStyle] = [.pageSheet, .fullScreen]
        try styles.forEach(test)
    }

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
            let _: UIViewController = try self.assertControllerEvent(
                from: vc0,
                to: { vc1 },
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
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                        }
                        else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear])
                        }
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear])
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear])
                        
                    default:
                        ()
                    }

            },
                onViewDidAppear: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                        }
                        else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        }
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                        
                    default:
                        ()
                    }

            })
        }
        
        try testSupportedStyles(test)
    }
    
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
            let _: UIViewController = try self.assertControllerEvent(
                from: vc0,
                to: { vc1 },
                when: { vc0.present(vc1, animated: false, completion: nil) },
                onViewDidLoad: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    XCTAssertEqual(vc0.lifeCycleEvents, [])
                    XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad])
    
            },
                onViewWillAppear: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                            XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear])
                        }
                        else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                            XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                        }
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                        
                    default:
                        ()
                    }

            },
                onViewDidAppear: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                        }
                        else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        }
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewDidLoad, .viewWillAppear, .viewDidAppear])
                        
                    default:
                        ()
                    }

            })
        }
        
        try testSupportedStyles(test)
    }
    
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
            let _: UIViewController = try self.assertControllerEvent(
                from: vc0,
                to: { vc1 },
                when: { vc0.dismiss(animated: true, completion: nil) },
                onViewWillAppear: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                        }
                        else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear])
                        }
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear])
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear])
                        
                    default:
                        ()
                    }

            },
                onViewDidAppear: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                        }
                        else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                        }
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        
                    default:
                        ()
                    }

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
            let _: UIViewController = try self.assertControllerEvent(
                from: vc0,
                to: { vc1 },
                when: { vc0.dismiss(animated: false, completion: nil) },
                onViewWillAppear: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                            XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear])
                        } else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                            XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        }
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        
                    default:
                        ()
                    }

            },
                onViewDidAppear: { presenting, presented in
                    XCTAssertTrue(presenting === vc0)
                    XCTAssertTrue(presented === vc1)
                    switch style {
                        
                    case .pageSheet:
                        if #available(iOS 13.0, *) {
                            XCTAssertEqual(vc0.lifeCycleEvents, [])
                        } else {
                            XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                        }
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        
                    case .fullScreen:
                        XCTAssertEqual(vc0.lifeCycleEvents, [.viewWillAppear, .viewDidAppear])
                        XCTAssertEqual(vc1.lifeCycleEvents, [.viewWillDisappear, .viewDidDisappear])
                        
                    default:
                        ()
                    }

            })
        }
        
        try testSupportedStyles(test)
    }

}
