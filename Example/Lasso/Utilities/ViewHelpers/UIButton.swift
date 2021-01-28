//
// ==----------------------------------------------------------------------== //
//
//  UIButton.swift
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

extension UIButton {
    
    convenience init(standardButtonWithTitle title: String) {
        self.init(type: .custom)
        setTitle(title, for: .normal)
        set(cornerRadius: 5)
        setBackgroundImage(.create(withColor: UIColor.blue.withAlphaComponent(0.5)), for: .normal)
        setBackgroundImage(.create(withColor: UIColor.gray.withAlphaComponent(0.5)), for: .disabled)
        layout.height(44)
    }
    
    @discardableResult
    public func set(title: String, with font: UIFont?) -> UIButton {
        if let font = font {
            let attribs: [NSAttributedString.Key: Any] = [.font: font]
            self.setAttributedTitle(NSAttributedString(string: title, attributes: attribs), for: .normal)
        }
        else {
            self.setTitle(title, for: .normal)
        }
        return self
    }
    
}
