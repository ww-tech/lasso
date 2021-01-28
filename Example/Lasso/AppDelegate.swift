//
// ==----------------------------------------------------------------------== //
//
//  AppDelegate.swift
//
//  Created by yuichi-kuroda-ww on 04/30/2019.
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
import Lasso

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        if Testing.active {
            // If the app is the host for unit tests, then skip the normal view controller setup:
            window.rootViewController = UIViewController()
            
            // Also turn off standard view animations to help speed up Flow unit tests:
            UIView.setAnimationsEnabled(false)
        }
        else {
            SampleCatalogFlow().start(with: root(of: window).withNavigationEmbedding())
        }
        
        window.backgroundColor = .background
        window.makeKeyAndVisible()
        
        return true
    }

}
