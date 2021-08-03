//
// ==----------------------------------------------------------------------== //
//
//  SwiftUI+Lasso.swift
//
//  Created by Charles Pisciotta on 07/14/2021
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2021 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Alert.Button {

    public static func `default`<Target: ActionDispatchable>(label: Text, for target: Target, action: Target.Action) -> Self {
        self.default(label) { target.dispatchAction(action) }
    }
    
    public static func destructive<Target: ActionDispatchable>(label: Text, for target: Target, action: Target.Action) -> Self {
        self.destructive(label) { target.dispatchAction(action) }
    }

    public static func cancel<Target: ActionDispatchable>(label: Text, for target: Target, action: Target.Action) -> Self {
        self.cancel(label) { target.dispatchAction(action) }
    }
}

#endif
