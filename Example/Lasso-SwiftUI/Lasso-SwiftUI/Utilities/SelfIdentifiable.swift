//
// ==----------------------------------------------------------------------== //
//
//  SelfIdentifiable.swift
//
//  Created by Steven Grosmark on 03/23/2021.
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

import Foundation

/// `Identifiable` that uses `self` for the `id` value.  Useful for enums w/o associated values.
protocol SelfIdentifiable: Identifiable {
    var id: Self { get }
}

extension SelfIdentifiable where Self: Hashable {
    var id: Self { self }
}
