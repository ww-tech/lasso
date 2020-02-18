//
//===----------------------------------------------------------------------===//
//
//  XCTestCase+Mockable.swift
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
//===----------------------------------------------------------------------===//
//

import XCTest
import Lasso

#if swift(>=5.1)
extension XCTestCase {
    
    public func mock<T>(_ mockable: Mockable<T>.Projected, with mock: @autoclosure () -> T?) {
        mockable.mock(with: mock())
        addTeardownBlock {
            mockable.reset()
        }
    }
}
#endif
