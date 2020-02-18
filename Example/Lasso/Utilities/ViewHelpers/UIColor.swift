//
//===----------------------------------------------------------------------===//
//
//  UIColor.swift
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

extension UIColor {
    
    static var background: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        }
        else {
            return UIColor.white
        }
    }
    
    static var text: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemFill
        }
        else {
            return UIColor.black
        }
    }
    
    #if canImport(SwiftUI)
    #else
    static let systemBackground: UIColor = .white
    static let systemFill: UIColor = .black
    static let systemGray2: UIColor = .lightGray
    #endif
}
