//
// ==----------------------------------------------------------------------== //
//
//  UIKitHelpers.swift
//
//  Created by Steven Grosmark on 12/11/19.
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

#if swift(>=5.0)
#else
enum Result<T, E> {
    case success(T)
    case failure(E)
}
#endif
