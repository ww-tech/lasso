//
// ==----------------------------------------------------------------------== //
//
//  ObjectBindingTests.swift
//
//  Created by Steven Grosmark on 6/5/19.
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
@testable import Lasso

class ObjectBindingTests: XCTestCase {

    private var instance: TestClass?
    
    override func setUp() {
        super.setUp()
        instance = TestClass()
    }
    
    func test_ObjectBinding_ReleaseWhenOwnerReleased() {
        
        // given
        weak var weakInstance = instance
        XCTAssertNotNil(instance, "instance shouldn't be nil")
        XCTAssertNotNil(weakInstance, "weakInstance shouldn't be nil")
        
        autoreleasepool {
            
            // when
            var view: UIView? = UIView()
            if let notOptionalInstance = instance {
                view?.holdReference(to: notOptionalInstance)
                instance = nil
            }
            
            // then
            XCTAssertNil(instance, "instance should be nil")
            XCTAssertNotNil(weakInstance, "weakInstance shouldn't be nil")
            
            // when
            view = nil
        }
        
        // then
        XCTAssertNil(weakInstance, "weakInstance should be nil")
    }
    
    func test_ObjectBinding_ManyObjectsSingleOwner() {
        
        // given
        var instances: [TestClass]? = [TestClass(), TestClass(), TestClass(), TestClass(), TestClass()]
        let weakInstances = instances?.map { WeakBox($0) } ?? []
        XCTAssertEqual(instances?.count, 5)
        XCTAssertEqual(instances?.count, weakInstances.compactMap({ $0.value }).count)
        
        autoreleasepool {
            
            // when
            var view: UIView? = UIView()
            instances?.forEach {
                view?.holdReference(to: $0)
            }
            instances = nil
            
            // then
            XCTAssertEqual(weakInstances.compactMap({ $0.value }).count, 5, "There should be 5 remaining")
            
            // when
            view = nil
        }
        
        // then
        XCTAssertTrue(weakInstances.compactMap({ $0.value }).isEmpty, "None should be remaining")
    }
    
    func test_WeakBox() {
        
        // given
        let weakBox = WeakBox(instance.unsafelyUnwrapped)
        XCTAssertNotNil(weakBox.value, "instance should be nil")
        
        // when
        instance = nil
        
        // then
        XCTAssertNil(weakBox.value, "instance should be nil")
    }
    
    func test_ObjectBinding_ManualRelease() {
        
        // given
        let view: UIView = UIView()
        let weakBox = WeakBox(instance.unsafelyUnwrapped)
        XCTAssertNotNil(instance, "instance shouldn't be nil")
        XCTAssertNotNil(weakBox.value, "weakInstance shouldn't be nil")
        
        autoreleasepool {
            
            // when
            view.holdReference(to: instance.unsafelyUnwrapped)
            instance = nil
            
            // then
            XCTAssertNil(instance, "instance should be nil")
            XCTAssertNotNil(weakBox.value, "weakInstance shouldn't be nil")
            
            // when
            view.releaseReference(to: weakBox.value.unsafelyUnwrapped)
        }
        
        // then
        XCTAssertNil(weakBox.value, "weakInstance should be nil")
        XCTAssertNotNil(view, "view shouldn't be nil")
    }
    
    func test_ObjectBinding_ManualReleaseOneOfMany() {
        
        // given
        var extraInstance: TestClass? = TestClass()
        let view: UIView = UIView()
        let weakBox1 = WeakBox(instance.unsafelyUnwrapped)
        let weakBox2 = WeakBox(extraInstance.unsafelyUnwrapped)
        XCTAssertNotNil(instance, "instance shouldn't be nil")
        XCTAssertNotNil(extraInstance, "extraInstance shouldn't be nil")
        XCTAssertNotNil(weakBox1.value, "weakInstance1 shouldn't be nil")
        XCTAssertNotNil(weakBox2.value, "weakInstance2 shouldn't be nil")
        
        autoreleasepool {
            
            // when
            view.holdReference(to: instance.unsafelyUnwrapped)
            view.holdReference(to: extraInstance.unsafelyUnwrapped)
            instance = nil
            extraInstance = nil
            
            // then
            XCTAssertNil(instance, "instance should be nil")
            XCTAssertNil(extraInstance, "extraInstance should be nil")
            XCTAssertNotNil(weakBox1.value, "weakInstance1 shouldn't be nil")
            XCTAssertNotNil(weakBox2.value, "weakInstance2 shouldn't be nil")
            
            // when
            view.releaseReference(to: weakBox1.value.unsafelyUnwrapped)
        }
        
        // then
        XCTAssertNil(instance, "instance should be nil")
        XCTAssertNil(extraInstance, "extraInstance should be nil")
        XCTAssertNil(weakBox1.value, "weakInstance1 should be nil")
        XCTAssertNotNil(weakBox2.value, "weakInstance2 shouldn't be nil")
        XCTAssertNotNil(view, "view shouldn't be nil")
    }

}

private class TestClass { }

private class WeakBox<Value: AnyObject> {
    weak var value: Value?
    init(_ value: Value) {
        self.value = value
    }
}
