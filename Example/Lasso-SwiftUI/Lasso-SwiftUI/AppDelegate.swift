//
// ==----------------------------------------------------------------------== //
//
//  AppDelegate.swift
//
//  Created by Steven Grosmark on 03/23/2021.
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

import UIKit
import Lasso

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.backgroundColor = .white
        
        AppCatalogFlow().start(with: root(of: window).withNavigationEmbedding())
        
        window.makeKeyAndVisible()
        
        return true
    }
    
}
