//
//===----------------------------------------------------------------------===//
//
//  ValueBinder.swift
//
//  Created by Trevor Beasty on 5/2/19.
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

import Foundation

internal final class ValueBinder<Value> {
    
    internal typealias Observer<T> = (T?, T) -> Void
    
    public private(set) var value: Value
    private var observers: [Observer<Value>] = []
    
    internal init(_ value: Value) {
        self.value = value
    }
    
    internal func set(_ newValue: Value) {
        let oldValue = value
        value = newValue
        executeOnMainThread { [weak self] in
            // Dispatch to all observers which exist at execution time - it is possible that additional
            // observers could be added b/w queuing and execution.
            self?.observers.forEach({ $0(oldValue, newValue) })
        }
    }
    
    private func observe(_ handler: @escaping Observer<Value>) {
        handler(nil, value)
        observers.append(handler)
    }
    
    internal func bind(to handler: @escaping Observer<Value>) {
        observe(handler)
    }
    
    internal func bind<T>(_ keyPath: KeyPath<Value, T>, to handler: @escaping Observer<T>) {
        observe { oldValue, newValue in
            let oldKeyValue = oldValue?[keyPath: keyPath]
            let newKeyValue = newValue[keyPath: keyPath]
            handler(oldKeyValue, newKeyValue)
        }
    }
    
    internal func bind<T>(_ keyPath: KeyPath<Value, T>, to handler: @escaping Observer<T>) where T: Equatable {
        observe { oldValue, newValue in
            let oldKeyValue = oldValue?[keyPath: keyPath]
            let newKeyValue = newValue[keyPath: keyPath]
            guard oldKeyValue != newKeyValue else { return }
            handler(oldKeyValue, newKeyValue)
        }
    }
    
}

extension ValueBinder where Value: Equatable {
    
    internal func bind(to handler: @escaping Observer<Value>) {
        observe { oldValue, newValue in
            guard oldValue != newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
}
