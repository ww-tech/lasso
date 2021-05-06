//
// ==----------------------------------------------------------------------== //
//
//  TypeCast.swift
//
//  Created by Trevor Beasty on 9/4/19.
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

extension XCTestCase {
    
    internal func typeCast<Instance, Type>(_ instance: @autoclosure () -> Instance?, file: StaticString = #file, line: UInt = #line) throws -> Type {
        
        guard let instance = instance() else {
            throw TypeCastError<Instance, Type>.failedToResolveInstance
        }
        
        guard let casted = instance as? Type else {
            throw TypeCastError<Instance, Type>.unexpectedInstanceType(instance: instance)
        }
        
        return casted
    }
    
}

extension UIViewController {
    
    public func firstChildOfType<A>(file: StaticString = #file, line: UInt = #line) throws -> A {
        guard let child = children.first(where: { $0 is A }) as? A else {
            let failedTest = FailedTest(error: ChildViewControllerError.controllerDoesNotHaveChildOfType(controller: self, childType: A.self),
                                        file: file,
                                        line: line)
            throw log(failedTest)
        }
        return child
    }
    
}

enum ChildViewControllerError<ChildType>: LassoError {
    case controllerDoesNotHaveChildOfType(controller: UIViewController, childType: ChildType)
    
    func message(verbose: Bool) -> String {
        switch self {
            
        case let .controllerDoesNotHaveChildOfType(controller: controller, childType: childType):
            return "Expected controller \(String(describing: controller)) to have child of type \(String(describing: childType))"
        }
    }
    
}
