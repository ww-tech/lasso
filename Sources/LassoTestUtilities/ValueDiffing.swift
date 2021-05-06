//
// ==----------------------------------------------------------------------== //
//
//  ValueDiffing.swift
//
//  Created by Trevor Beasty on 9/9/19.
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

func messageDescribingDiffs<A>(_ realized: A, _ expected: A) -> String {
    return diffsHeader + stringDescribing(diff(realized: realized, expected: expected))
}

func messageDescribingDiffs<A>(_ realized: [A], _ expected: [A]) -> String {
    guard realized.count == expected.count else {
        return "\n\nCOUNTS DIFFER:\n  realized count   -->   \(realized.count)\n  expected count   -->   \(expected.count)"
    }
    if realized.count == 1 {
        return messageDescribingDiffs(realized[0], expected[0])
    }
    return diffsHeader + zip(realized, expected).enumerated()
        .compactMap({
            let diffs = diff(realized: $0.1.0, expected: $0.1.1)
            guard !diffs.isEmpty else { return nil }
            return "\nindex \($0.0)\n\(stringDescribing(diffs))"
        })
        .joined()
}

func diff<A>(realized: A, expected: A) -> [Diff] {
    return zip(stringsDescribing(realized), stringsDescribing(expected))
        .compactMap({
            if $0.0.value != $0.1.value {
                return Diff(key: $0.0.key, type: $0.0.type, realized: $0.0.value, expected: $0.1.value)
            }
            return nil
        })
}

struct Diff: Equatable {
    let key: String?
    let type: String
    let realized: String
    let expected: String
}

private func stringsDescribing<A>(_ value: A) -> [(key: String?, type: String, value: String)] {
    return Mirror(reflecting: value)
        .children
        .map({
            let _type = type(of: $0.value)
            return ($0.label, String(describing: _type), String(describing: $0.value))
        })
}

private func stringDescribing(_ diffs: [Diff]) -> String {
    return diffs
        .map({
            return "\($0.key ?? "_ "): \($0.type)   -->   \($0.realized)   !=   \($0.expected)"
        })
        .joined(separator: "\n")
}

private let diffsHeader = "\n\nDIFFS:   _ : T   -->   realized   !=   expected\n\n"
