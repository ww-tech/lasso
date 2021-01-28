//
// ==----------------------------------------------------------------------== //
//
//  UITableView.swift
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

extension UITableViewCell {
    static var identifier: String { return "\(type(of: self))" }
}

extension UITableView {
    
    func register<CellType: UITableViewCell>(type: CellType.Type) {
        register(CellType.self, forCellReuseIdentifier: CellType.identifier)
    }
    
    func dequeueCell<CellType: UITableViewCell>(type: CellType.Type, indexPath: IndexPath) -> CellType {
        guard let cell = dequeueReusableCell(withIdentifier: CellType.identifier, for: indexPath) as? CellType else {
            return CellType()
        }
        return cell
    }
    
}
