//
// ==----------------------------------------------------------------------== //
//
//  EdgeInsets+Zero.swift
//
//  Created by Steven Grosmark on 03/24/2021.
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

import SwiftUI

extension EdgeInsets {
    
    static let zero: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    public init(_ value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }
    
}
