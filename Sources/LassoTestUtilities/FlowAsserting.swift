//
//===----------------------------------------------------------------------===//
//
//  FlowAsserting.swift
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
//===----------------------------------------------------------------------===//
//

import XCTest
import Lasso

public extension Flow where Module.Output: Equatable {
    
    /// Assert that the event results in the stated outputs from the Flow.
    /// - Parameter event: the event which results in the outputs
    /// - Parameter outputs: the outputs resulting from the event
    /// - Parameter file: the file of the caller
    /// - Parameter line: the line of the caller
    func assert(when event: () -> Void, outputs: Output..., file: StaticString = #file, line: UInt = #line) {
        var _outputs: [Output] = []
        observeOutput { _outputs.append($0) }
        event()
        XCTAssertEqual(_outputs, outputs, file: file, line: line)
    }
    
}
