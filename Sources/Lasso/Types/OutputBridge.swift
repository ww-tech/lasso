//
// ==----------------------------------------------------------------------== //
//
//  OutputBridge.swift
//
//  Created by Steven Grosmark on 5/12/19.
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

internal final class OutputBridge<Output> {
    
    public init() {
    }
    
    internal func register(_ handler: @escaping (Output) -> Void) {
        outputObservers.append(handler)
    }
    
    internal func dispatch(_ output: Output) {
        executeOnMainThread { [weak self] in
            self?.outputObservers.forEach { $0(output) }
        }
    }
    
    private var outputObservers: [(Output) -> Void] = []
}
