//
// ==----------------------------------------------------------------------== //
//
//  LoginViewController.swift
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
import WWLayout

final class LoginViewController: UIViewController {
    
    private let store: LoginScreenModule.ViewStore
    
    private let headerLabel = UILabel(headline: "Login")
    private let usernameField = UITextField(placeholder: "Username")
    private let passwordField = UITextField(placeholder: "Password")
    private let loginButton = UIButton(standardButtonWithTitle: "Login")
    private let activityIndicator = UIActivityIndicatorView(style: .mediumGray)
    private let errorLabel = UILabel()
    
    init(store: LoginScreenModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    private func setupSubviews() {
        passwordField.isSecureTextEntry = true
        activityIndicator.hidesWhenStopped = true
        errorLabel.numberOfLines = 0
        
        view.addSubviews(headerLabel, usernameField, passwordField, loginButton, activityIndicator, errorLabel)
    }
    
    private func setupConstraints() {
        headerLabel.layout
            .top(to: .safeArea, offset: 50)
            .centerX(to: .safeArea)
        
        usernameField.layout
            .below(headerLabel, offset: 50)
            .fillWidth(of: .safeArea, inset: 20, maximum: 280)
        
        passwordField.layout
            .below(usernameField, offset: 30)
            .fillWidth(of: .safeArea, inset: 20, maximum: 280)
        
        loginButton.layout
            .below(passwordField, offset: 50)
            .fillWidth(of: .safeArea, inset: 20, maximum: 280)
        
        activityIndicator.layout
            .below(loginButton, offset: 20)
            .centerX(to: .safeArea)
        
        errorLabel.layout
            .below(activityIndicator, offset: 20)
            .fill(.safeArea, axis: .x, inset: 20)
    }
    
    private func setupBindings() {
        // State observations
        store.observeState(\.username) { [weak self] oldValue, username in
            self?.usernameField.text = username
        }
        store.observeState(\.password) { [weak self] password in
            self?.passwordField.text = password
        }
        store.observeState(\.canLogin) { [weak self] canLogin in
            self?.loginButton.isEnabled = canLogin
        }
        store.observeState(\.error) { [weak self] error in
            self?.errorLabel.text = error
        }
        store.observeState(\.phase) { [weak self] phase in
            self?.activityIndicator.animating = phase == .busy
            self?.view.isUserInteractionEnabled = phase == .idle
        }
        
        store.dispatchAction(<#T##viewAction: LoginScreenModule.Action##LoginScreenModule.Action#>)
        // User actions
        loginButton.bind(to: store, action: .didTapLogin)
        usernameField.bindTextDidChange(to: store, mapping: LoginScreenModule.Action.didEditUsername)
        passwordField.bindTextDidChange(to: store, mapping: LoginScreenModule.Action.didEditPassword)
    }
    
}
