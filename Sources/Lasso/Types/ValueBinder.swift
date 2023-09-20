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

internal actor ValueBinder<Value> {

    internal typealias Observer<T> = @Sendable (T?, T) async -> Void

    /// Current value held by the `ValueBinder` - for internal use only.
    internal private(set) var value: Value

    private var observers: [Observer<Value>] = []

    internal init(_ value: Value) {
        self.value = value
    }

    internal func set(_ newValue: Value) {
        let oldValue = value
        let handlers = observers
        value = newValue
        Task.detached {
            for work in handlers {
                await work(oldValue, newValue)
            }
        }
    }

    private func observe(_ handler: @escaping Observer<Value>) {
        let value = self.value
        observers.append(handler)
        Task.detached {
            await handler(nil, value)
        }
    }
    
    internal func bind(to handler: @escaping Observer<Value>) {
        observe(handler)
    }
    
    internal func bind<T>(_ keyPath: KeyPath<Value, T>, to handler: @escaping Observer<T>) {
        observe { oldValue, newValue in
            let oldKeyValue = oldValue?[keyPath: keyPath]
            let newKeyValue = newValue[keyPath: keyPath]
            await handler(oldKeyValue, newKeyValue)
        }
    }
    
    internal func bind<T>(_ keyPath: KeyPath<Value, T>, to handler: @escaping Observer<T>) where T: Equatable {
        observe { oldValue, newValue in
            let oldKeyValue = oldValue?[keyPath: keyPath]
            let newKeyValue = newValue[keyPath: keyPath]
            guard oldKeyValue != newKeyValue else { return }
            await handler(oldKeyValue, newKeyValue)
        }
    }
    
}

extension ValueBinder where Value: Equatable {
    
    internal func bind(to handler: @escaping Observer<Value>) {
        observe { oldValue, newValue in
            guard oldValue != newValue else { return }
            await handler(oldValue, newValue)
        }
    }
    
}
