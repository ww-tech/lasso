//
// ==----------------------------------------------------------------------== //
//
//  String+CamelCase.swift
//
//  Created by Steven Grosmark on 03/25/2021
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

import Foundation

protocol TitleConvertible {
    var title: String { get }
}

extension TitleConvertible {
    var title: String { "\(self)".convertCamelCaseToTitleCase() }
}

extension String {
    
    func convertCamelCaseToTitleCase() -> String {
        var wasUppercase = false
        var pending = ""
        var result = self.reduce(into: "") { result, ch in
            switch (ch.isUppercase, wasUppercase) {
            
            case (false, true):
                if !result.isEmpty, !result.hasSuffix(" ") {
                    result.append(" ")
                }
                result.append(pending)
                fallthrough
                
            case (false, false):
                result.append(ch)
                wasUppercase = false
                
            case (true, true):
                result.append(pending)
                pending = ch.lowercased()
                wasUppercase = true
                
            case (true, false):
                if !result.isEmpty, !result.hasSuffix(" ") {
                    result.append(" ")
                }
                pending = ch.lowercased()
                wasUppercase = true
            }
        }
        if wasUppercase {
            result.append(pending)
        }
        return result.first?.uppercased().appending(result.dropFirst()) ?? ""
    }
    
}
