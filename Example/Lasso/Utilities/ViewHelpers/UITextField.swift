//
//===----------------------------------------------------------------------===//
//
//  UITextField.swift
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
import WWLayout

extension UITextField {
    
    public convenience init(placeholder: String,
                            text: String = "",
                            autocorrect: UITextAutocorrectionType = .no,
                            autocapitalize: UITextAutocapitalizationType = .none) {
        self.init()
        let border = UIView()
        
        self.autocorrectionType = autocorrect
        self.autocapitalizationType = autocapitalize
        self.placeholder = placeholder
        self.addSubview(border)
        
        border.layout.fill(self, except: .top, inset: Insets(0, -4)).height(2)
        if #available(iOS 13.0, *) {
            border.backgroundColor = .systemGray2
        }
        else {
            border.backgroundColor = .lightGray
        }
    }
    
}
