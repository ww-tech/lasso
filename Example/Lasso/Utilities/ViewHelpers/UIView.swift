//
// ==----------------------------------------------------------------------== //
//
//  UIView.swift
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

extension UIView {
    
    public func addSubviews(_ views: UIView ...) {
        views.forEach(addSubview)
    }
    
    @discardableResult
    public func set(cornerRadius: CGFloat) -> UIView {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor, thickness: CGFloat) -> UIView {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = thickness
        return self
    }
    
}
