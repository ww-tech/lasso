//
// ==----------------------------------------------------------------------== //
//
//  StoreTesting+ThenAssertion.swift
//
//  Created by Trevor Beasty on 9/11/19.
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
import XCTest
import Lasso

public typealias ThenAssertion<Store: AbstractStore> = (_ thenable: EmittedValues<Store>, _ file: StaticString, _ line: UInt) -> Void

public func assert<Store: AbstractStore>(_ assert: @escaping (EmittedValues<Store>) -> Void) -> ThenAssertion<Store> {
    return { thenable, _, _ in
        assert(thenable)
    }
}

public func singleState<Store: AbstractStore>(_ state: Store.State) -> ThenAssertion<Store> where Store.State: Equatable {
    return { thenable, file, line in
        guard assertSingleElement(in: thenable.states, elementNames: stateNames, file: file, line: line) else { return }
        assertEqual(realized: thenable.states[0], expected: state, file: file, line: line)
    }
}

public func singleUpdate<Store: AbstractStore>(_ update: @escaping (inout Store.State) -> Void) -> ThenAssertion<Store> where Store.State: Equatable {
    return { thenable, file, line in
        guard assertSingleElement(in: thenable.states, elementNames: stateNames, file: file, line: line) else { return }
        var expected = thenable.previousState
        update(&expected)
        assertEqual(realized: thenable.states[0], expected: expected, file: file, line: line)
    }
}

public func state<Store: AbstractStore>(_ state: Store.State) -> ThenAssertion<Store> where Store.State: Equatable {
    return { thenable, file, line in
        guard let state = thenable.states.last else {
            XCTFail("no states emitted", file: file, line: line)
            return
        }
        assertEqual(realized: state, expected: state, file: file, line: line)
    }
}

public func update<Store: AbstractStore>(_ update: @escaping (inout Store.State) -> Void) -> ThenAssertion<Store> where Store.State: Equatable {
    return { thenable, file, line in
        guard let state = thenable.states.last else {
            XCTFail("no states emitted", file: file, line: line)
            return
        }
        var expected = thenable.previousState
        update(&expected)
        assertEqual(realized: state, expected: expected, file: file, line: line)
    }
}

public func outputs<Store: AbstractStore>(_ outputs: Store.Output...) -> ThenAssertion<Store> where Store.Output: Equatable {
    return { thenable, file, line in
        assertEqual(realized: thenable.outputs, expected: outputs, file: file, line: line)
    }
}

public func sideEffects<Store: AbstractStore>(_ sideEffect: @escaping () -> Void) -> ThenAssertion<Store> where Store.State: Equatable {
    return { _, _, _ in
        sideEffect()
    }
}

private func assertEqual<A: Equatable>(realized: A, expected: A, file: StaticString, line: UInt) {
    if realized != expected {
        XCTFail("realized differs from expected" + messageDescribingDiffs(realized, expected), file: file, line: line)
    }
}

private func assertEqual<A: Equatable>(realized: [A], expected: [A], file: StaticString, line: UInt) {
    if realized != expected {
        XCTFail("realized differs from expected" + messageDescribingDiffs(realized, expected), file: file, line: line)
    }
}

private let stateNames = ("state", "states")

private func assertSingleElement<A>(in array: [A], elementNames: (String, String), file: StaticString, line: UInt) -> Bool {
    if array.count != 1 {
        XCTFail("expected 1 \(elementNames.0), realized \(array.count) \(elementNames.1)", file: file, line: line)
    }
    return array.count == 1
}
