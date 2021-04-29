//
// ==----------------------------------------------------------------------== //
//
//  Compatibility.swift
//
//  Created by Steven Grosmark on 3/23/21
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

import UIKit

extension UIActivityIndicatorView.Style {
    
    static var mediumGray: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView.Style.medium
        }
        else {
            return UIActivityIndicatorView.Style.gray
        }
    }
    
    static var largeWhite: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView.Style.large
        }
        else {
            return UIActivityIndicatorView.Style.whiteLarge
        }
    }
    
}
