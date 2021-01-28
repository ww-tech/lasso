//
// ==----------------------------------------------------------------------== //
//
//  UIImage.swift
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

import UIKit

extension UIImage {
    
    /// Create a UIImage of a solid color
    ///
    /// - Parameters:
    ///   - color: The color of the resulting image
    ///   - size: The new image dimensions
    /// - Returns: a new UIImage
    public static func create(withColor color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
