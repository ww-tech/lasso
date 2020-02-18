//
//===----------------------------------------------------------------------===//
//
//  ObjectBinding.swift
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
//===----------------------------------------------------------------------===//
//

import UIKit

/// Objects that can hold strong references to other objects
public protocol ObjectBindable: AnyObject {
    func holdReference(to object: AnyObject)
    func releaseReference(to object: AnyObject)
}

// This is a common ancestor to UIGestureRecognizers, as well as all other UIKit classes
extension NSObject: ObjectBindable { }

extension ObjectBindable {
    
    /// Hold a strong reference to `object`.
    /// The reference will be released when the target ObjectBindable is released.
    ///
    /// - Parameter object: The instance to hold a strong reference to.
    public func holdReference(to object: AnyObject) {
        var boundObjects = objc_getAssociatedObject(self, &BoundObjects.associationKey) as? BoundObjects.Dictionary ?? [:]
        boundObjects[ObjectIdentifier(object)] = object
        objc_setAssociatedObject(self, &BoundObjects.associationKey, boundObjects, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Release a previously held strong reference to `object`
    ///
    /// - Parameter object: The instance to let go of.
    public func releaseReference(to object: AnyObject) {
        guard var boundObjects = objc_getAssociatedObject(self, &BoundObjects.associationKey) as? BoundObjects.Dictionary else { return }
        boundObjects.removeValue(forKey: ObjectIdentifier(object))
        if boundObjects.isEmpty {
            objc_setAssociatedObject(self, &BoundObjects.associationKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        else {
            objc_setAssociatedObject(self, &BoundObjects.associationKey, boundObjects, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

private enum BoundObjects {
    
    typealias Dictionary = [ObjectIdentifier: AnyObject]
    
    static var associationKey: Int = 0
    
}
