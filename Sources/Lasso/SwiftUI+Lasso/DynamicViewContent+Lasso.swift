//
// ==----------------------------------------------------------------------== //
//
//  DynamicViewContent+Lasso.swift
//
//  Created by Charles Pisciotta on 8/9/21
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

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension DynamicViewContent {

    public func onDelete<Target: ActionDispatchable>(_ target: Target, action: @escaping (IndexSet) -> Target.Action) -> some DynamicViewContent {
        onDelete { target.dispatchAction(action($0)) }
    }

}

#endif
