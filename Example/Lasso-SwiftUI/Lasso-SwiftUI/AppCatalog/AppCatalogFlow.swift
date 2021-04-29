//
// ==----------------------------------------------------------------------== //
//
//  AppCatalogFlow.swift
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

final class AppCatalogFlow: Flow<NoOutputNavigationFlow> {
    
    override func createInitialController() -> UIViewController {
        AppCatalogScreen
            .createScreen()
            .observeOutput { [weak self] in self?.handleOutput($0) }
            .controller
    }
    
    private func handleOutput(_ output: AppCatalogScreen.Output) {
        switch output {
        
        case .simpleCounter:
            SimpleCounter
                .createScreen()
                .place(with: nextPushedInFlow)
            
        case .login:
            Login
                .createScreen()
                .observeOutput { [weak self] _ in self?.unwind() }
                .place(with: nextPushedInFlow)
            
        case .welcome:
            WelcomeOnboardingFlow()
                .observeOutput { [weak self] _ in self?.unwind() }
                .start(with: nextPresentedInFlow?.withDismissibleNavigationEmbedding())
        }
    }
}
