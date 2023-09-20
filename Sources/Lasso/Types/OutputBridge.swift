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

internal actor OutputBridge<Output> {
    
    typealias OutputHandler = @Sendable (Output) async -> Void
    
    public init() {
    }
    
    internal func register(_ handler: @escaping OutputHandler) {
        outputObservers.append(handler)
    }
    
    internal func dispatch(_ output: Output) {
        let observers = outputObservers
        Task.detached {
            await withTaskGroup(of: Void.self) { group in
                for observer in observers {
                    group.addTask {
                        await observer(output)
                    }
                }
            }
        }
    }
    
    private var outputObservers: [OutputHandler] = []
}
