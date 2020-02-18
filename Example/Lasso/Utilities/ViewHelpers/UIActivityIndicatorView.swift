//
//===----------------------------------------------------------------------===//
//
//  UIActivityIndicatorView.swift
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

import UIKit

extension UIActivityIndicatorView {
    
    public var animating: Bool {
        set {
            if newValue { startAnimating() }
            else { stopAnimating() }
        }
        get {
            return isAnimating
        }
    }
}
