//
// ==----------------------------------------------------------------------== //
//
//  VerboseLoggingTests.swift
//
//  Created by Trevor Beasty on 12/10/19.
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
@testable import LassoTestUtilities

class VerboseLoggingTests: XCTestCase {

    func test_NavigationEmbedding() {
        let navigationController = UINavigationController(rootViewController: VC1())
        
        let description = describeViewControllerHierarchy(navigationController)
        
        XCTAssertEqual(description, "<UINavigationController : [VC1]>")
    }
    
    func test_ModalSequence() {
        let window = UIWindow()
        window.makeKeyAndVisible()
        let vc1 = VC1()
        let vc2 = VC2()
        window.rootViewController = vc1
        vc1.present(vc2, animated: false, completion: nil)
        
        let description = describeViewControllerHierarchy(vc2)
        
        XCTAssertEqual(description, "<VC1> --> <VC2>")
    }
    
    func test_ModalSequenceWithNavigationController() {
        let window = UIWindow()
        window.makeKeyAndVisible()
        let navigationController = UINavigationController(rootViewController: VC1())
        let vc2 = VC2()
        window.rootViewController = navigationController
        navigationController.pushViewController(UIViewController(), animated: false)
        navigationController.present(vc2, animated: false, completion: nil)
        
        let description = describeViewControllerHierarchy(vc2)
        
        XCTAssertEqual(description, "<UINavigationController : [VC1, UIViewController]> --> <VC2>")
    }

}

private class VC1: UIViewController { }

private class VC2: UIViewController { }
