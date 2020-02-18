//
//===----------------------------------------------------------------------===//
//
//  UIGestureRecognizer+SendActions.swift
//
//  Created by Steven Grosmark on 6/5/19.
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

// UIGestureRecognizer extension
extension  UIGestureRecognizer {
    
    /// Executes all targets on a gesture recognizer
    func sendActions() {
        let targetsInfo = getTargetInfo()
        for info in targetsInfo {
            _ = info.target.perform(info.action)
            //info.target.performSelector(onMainThread: info.action, with: self, waitUntilDone: true)
        }
    }
    
    // MARK: Retrieving targets from gesture recognizers
    
    /// Returns all actions and selectors for a gesture recognizer
    /// This method uses private API's and will most likely cause your app to be rejected if used outside of your test target
    /// - Returns: [(target: AnyObject, action: Selector)] Array of action/selector tuples
    private func getTargetInfo() -> TargetActionInfo {
        guard let targets = value(forKeyPath: "_targets") as? [NSObject] else {
            return []
        }
        var targetsInfo: TargetActionInfo = []
        for target in targets {
            // Getting selector by parsing the description string of a UIGestureRecognizerTarget
            let description = String(describing: target).trimmingCharacters(in: CharacterSet(charactersIn: "()"))
            var selectorString = description.components(separatedBy: ", ").first ?? ""
            selectorString = selectorString.components(separatedBy: "=").last ?? ""
            let selector = NSSelectorFromString(selectorString)
            
            // Getting target from iVars
            if let targetActionPairClass = NSClassFromString("UIGestureRecognizerTarget"),
                let targetIvar = class_getInstanceVariable(targetActionPairClass, "_target"),
                let targetObject = object_getIvar(target, targetIvar) {
                targetsInfo.append((target: targetObject as AnyObject, action: selector))
            }
        }
        
        return targetsInfo
    }
    
}

// Return type alias
private typealias TargetActionInfo = [(target: AnyObject, action: Selector)]
