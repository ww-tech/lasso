//
//===----------------------------------------------------------------------===//
//
//  StoreTesting.swift
//
//  Created by Trevor Beasty on 9/3/19.
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
import Lasso
import XCTest

public struct EmittedValues<Store: AbstractStore> {
    let store: Store
    let teardown: () -> Void
    public let previousState: Store.State
    public let states: [Store.State]
    public let outputs: [Store.Output]
}

public protocol LassoStoreTesting {
    associatedtype Store: ConcreteStore
    typealias State = Store.State
    typealias Action = Store.Action
    typealias Output = Store.Output
    var test: TestFactory<Store> { get }
}

public struct TestFactory<Store: ConcreteStore> {
    
    public let initialState: Store.State
    private let setUpStore: (Store) -> Void
    private let tearDown: () -> Void
    
    public init(initialState: Store.State, setUpStore: @escaping (Store) -> Void, tearDown: @escaping () -> Void) {
        self.initialState = initialState
        self.setUpStore = setUpStore
        self.tearDown = tearDown
    }
    
    public func given(_ given: @escaping (inout Store.State) -> Void) -> TestNode<Store>.When {
        return TestNode<Store>.When {
            var state = self.initialState
            given(&state)
            let store = Store(with: state)
            self.setUpStore(store)
            return Whenable<Store>(store: store, teardown: self.tearDown)
        }
    }
        
}

public enum TestNode<Store: AbstractStore> {
    
    public struct When {
        let runPrevious: () -> Whenable<Store>
        
        public func when(_ statement: @escaping WhenStatement<Store.Action>) -> Then {
            return Then {
                let info = self.runPrevious()
                var states = [Store.State]()
                var outputs = [Store.Output]()
                info.store.observeState { _, new in states.append(new) }
                info.store.observeOutput { outputs.append($0) }
                let previousState = states.removeFirst()
                statement(info.store.dispatchAction)
                return EmittedValues(store: info.store, teardown: info.teardown, previousState: previousState, states: states, outputs: outputs)
            }
        }
        
        public func execute() {
            let info = runPrevious()
            info.teardown()
        }
        
    }

    public class Then {
        let runPrevious: () -> EmittedValues<Store>
        let didExecute: () -> Bool
        var file: StaticString?
        var line: UInt?
        
        init(runPrevious: @escaping () -> EmittedValues<Store>) {
            var didExecute = false
            self.runPrevious = {
                defer { didExecute = true }
                return runPrevious()
            }
            self.didExecute = { return didExecute }
        }
        
        deinit {
            if !didExecute(), let file = file, let line = line {
                XCTFail("CRITICAL: 'then assertion' never executed", file: file, line: line)
            }
        }
        
        public func then(_ assertions: ThenAssertion<Store>..., file: StaticString = #file, line: UInt = #line) -> When {
            self.file = file
            self.line = line
            return When {
                let info = self.runPrevious()
                assertions.forEach { $0(info, file, line) }
                return Whenable<Store>(store: info.store, teardown: info.teardown)
            }
        }
        
    }
    
}

struct Whenable<Store: AbstractStore> {
    let store: Store
    let teardown: () -> Void
}

private func valuesFor<A>(_ initialValue: A, _ updates: [(inout A) -> Void]) -> [A] {
    var current = initialValue
    var values = [A]()
    for update in updates {
        update(&current)
        values.append(current)
    }
    return values
}
