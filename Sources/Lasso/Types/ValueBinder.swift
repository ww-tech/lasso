//
// ==----------------------------------------------------------------------== //
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
// ==----------------------------------------------------------------------== //
//

import Foundation

internal final class ValueBinder<Value> {

    internal typealias Observer<T> = (T?, T) -> Void

    /// Current value held by the `ValueBinder`.
    public var value: Value {
        var value: Value!
        valueQueue.sync {
            value = _value
        }
        return value
    }

    /// Current value held by the `ValueBinder` - for internal use only, and only when inside a `valueQueue.sync` block.
    private var _value: Value

    /// Access only within a `valueQueue.sync` block
    private var observers: [Observer<Value>] = []

    /// Protects access to both `value` and `observers` for `sync` access only
    private let valueQueue = DispatchQueue(label: "value-binder-sync-queue", target: .global())

    internal init(_ value: Value) {
        self._value = value
    }

    internal func set(_ newValue: Value) {
        var oldValue: Value!
        var handlers: [(Value?, Value) -> Void]!
        valueQueue.sync {
            oldValue = _value
            self._value = newValue
            handlers = self.observers
        }
        executeOnMainThread {
            // Dispatch to all observers which exist at execution time - it is possible that additional
            // observers could be added b/w queuing and execution.
            handlers.forEach({ $0(oldValue, newValue) })
        }
    }

    private func observe(_ handler: @escaping Observer<Value>) {
        var value: Value!
        valueQueue.sync {
            value = self._value
            observers.append(handler)
        }
        executeOnMainThread {
            handler(nil, value)
        }
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
