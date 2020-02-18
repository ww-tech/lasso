//
//===----------------------------------------------------------------------===//
//
//  UILabel.swift
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

extension UILabel {
    
    public convenience init(headline: String?) {
        self.init()
        commonInit(.systemFont(ofSize: 40, weight: .regular), text: headline)
    }
    
    public convenience init(body: String?, size: CGFloat = 20, weight: UIFont.Weight = .regular) {
        self.init()
        commonInit(.systemFont(ofSize: size, weight: weight), text: body)
    }
    
    private func commonInit(_ font: UIFont, text: String?) {
        self.font = font
        self.numberOfLines = 0
        self.text = text
    }
    
}
