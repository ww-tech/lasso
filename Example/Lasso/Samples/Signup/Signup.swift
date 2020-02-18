//
//===----------------------------------------------------------------------===//
//
//  Signup.swift
//
//  Created by Steven Grosmark on 5/18/19.
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
import Lasso

enum Signup: NavigationFlowModule {
    
    enum Output: Equatable {
        case didCompleteSignup
        case didFailSignup
    }
    
}

class SignupFlow: Flow<Signup> {
    
    override func createInitialController() -> UIViewController {
        return
            SignupIntro
                .createScreen()
                .observeOutput { [weak self] in self?.handle(ScreenOutput.intro($0)) }
                .controller
    }
    
    private func handle(_ output: ScreenOutput) {
        switch output {
            
        case .intro(.didTapNext):
            SignupForm
                .createScreen()
                .observeOutput { [weak self] in self?.handle(ScreenOutput.form($0)) }
                .place(with: nextPushedInFlow)
            
        case .form(.didSignup(let fields)):
            formFields = fields
            let textState = TextScreenModule.State(title: "All set",
                                                   description: "Ok, \(formFields.name), let's get started!",
                                                   buttons: ["Finish"])
            TextScreenModule
                .createScreen(with: textState)
                .place(with: nextPushedInFlow)
                .setUpController { $0.navigationItem.hidesBackButton = true }
                .observeOutput { [weak self] in self?.handle(ScreenOutput.finished($0)) }
            
        case .finished(.didTapButton):
            dispatchOutput(.didCompleteSignup)
        }
    }
    
    enum ScreenOutput {
        case intro(SignupIntro.Output)
        case form(SignupForm.Output)
        case finished(TextScreenModule.Output)
    }
    
    private var formFields = SignupForm.Output.Fields()
}
