//
//===----------------------------------------------------------------------===//
//
//  SignupForm.swift
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

// MARK: - Module

enum SignupForm: ScreenModule {
    
    enum Output: Equatable {
        case didSignup(Fields)
        
        struct Fields: Equatable {
            let name: String
            let email: String
            let username: String
            let password: String
        }
    }
    
    enum Action: Equatable {
        case didUpdate(Field, String)
        case didTapSignup
    }
    
    struct State: Equatable {
        var name: Validated
        var email: Validated
        var username: Validated
        var password: Validated
        var formIsValid: Bool = false
        var phase: Phase
        enum Phase: Equatable { case idle, working, error(String) }
    }
    
    struct Validated: Equatable {
        let value: String
        let error: String?
    }
    
    enum Field: CaseIterable {
        case name, email, username, password
    }
    
    static func createScreen(with formFields: Output.Fields) -> Screen {
        return SignupForm.createScreen(with: State(from: formFields))
    }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: SignupFormStore) -> Screen {
        let controller = SignupFormViewController(viewStore: store.asViewStore())
        return Screen(store, controller)
    }
    
}

// MARK: - Store

class SignupFormStore: LassoStore<SignupForm> {
    
    var signupService: SignupServiceProtocol = SignupService()
    
    override func handleAction(_ action: SignupForm.Action) {
        switch action {
            
        case .didUpdate(let field, let value):
            update { state in
                state[keyPath: field.stateKey] = field.validate(value.trimmingCharacters(in: .whitespacesAndNewlines))
                state.formIsValid = state.areAllFormFieldsValid()
            }
        
        case .didTapSignup:
            guard state.formIsValid, state.phase == .idle else { return }
            goSignup()
        }
    }
    
    private func goSignup() {
        update { state in state.phase = .working }
        signupService.signup(state.completedFields) { [ weak self] _ in
            guard let self = self else { return }
            self.dispatchOutput(.didSignup(self.state.completedFields))
        }
    }
}

protocol SignupServiceProtocol {
    func signup(_ fields: SignupForm.Output.Fields, completion: @escaping (Result<String, Error>) -> Void)
}

struct SignupService: SignupServiceProtocol {
    
    func signup(_ fields: SignupForm.Output.Fields, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            completion(.success(UUID().uuidString))
        }
    }
    
}

extension SignupForm.Output.Fields {
    init() {
        name = ""
        email = ""
        username = ""
        password = ""
    }
}

extension SignupForm.Field {
    typealias State = SignupForm.State
    typealias Validated = SignupForm.Validated
    
    var label: String { return "\(self)".capitalized }
    
    var stateKey: WritableKeyPath<State, Validated> {
        switch self {
        case .name: return \.name
        case .email: return \.email
        case .username: return \.username
        case .password: return \.password
        }
    }
    
    func validate(_ value: String) -> Validated {
        switch self {
        case .name: return validate(value, using: "^.{3,64}$")
        case .email: return validate(value, using: "^[^@]+@.+\\.[^.]{2,}$")
        case .username: return validate(value, using: "^[a-zA-Z0-9_]{3,64}$")
        case .password: return validate(value, using: "^.{3,64}$")
        }
    }
    
    func validate(_ value: String, using regex: String) -> Validated {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = trimmed.range(of: regex, options: .regularExpression) != nil
        return Validated(value: value, error: isValid ? nil : "Invalid")
    }
}

extension SignupForm.State {
    typealias Field = SignupForm.Field
    typealias Validated = SignupForm.Validated
    
    init() {
        name = Validated()
        email = Validated()
        username = Validated()
        password = Validated()
        phase = .idle
        formIsValid = false
    }
    
    init(from formFields: SignupForm.Output.Fields) {
        name = Field.name.validate(formFields.name)
        email = Field.email.validate(formFields.email)
        username = Field.username.validate(formFields.username)
        password = Field.name.validate(formFields.password)
        phase = .idle
        formIsValid = areAllFormFieldsValid()
    }
    
    var completedFields: SignupForm.Output.Fields {
        return SignupForm.Output.Fields(name: name.value,
                                        email: email.value,
                                        username: username.value,
                                        password: password.value)
    }
    
    fileprivate func areAllFormFieldsValid() -> Bool {
        for field in SignupForm.Field.allCases {
            let validated = self[keyPath: field.stateKey]
            if validated.error != nil || validated.value.isEmpty {
                return false
            }
        }
        return true
    }
}

extension SignupForm.Validated {
    init() {
        value = ""
        error = nil
    }
}

// MARK: - View Controller

class SignupFormViewController: UIViewController {
    
    private let viewStore: SignupForm.ViewStore
    private let activityIndicator = UIActivityIndicatorView()
    
    init(viewStore: SignupForm.ViewStore) {
        self.viewStore = viewStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        let headerLabel = UILabel(headline: "Setup your account")
        
        view.addSubview(headerLabel)
        headerLabel.layout.fill(.safeArea, except: .bottom, inset: 30)
        
        var last: UIView = headerLabel
        
        for field in SignupForm.Field.allCases {
            let (textField, errorLabel) = makeFormFieldAndLabel(for: field)
            
            view.addSubviews(textField, errorLabel)
            textField.layout
                .below(last, offset: 30)
                .fillWidth(of: .safeArea, inset: 30, maximum: 420)
            errorLabel.layout
                .below(textField, offset: 10)
                .fill(textField, axis: .x)
            last = errorLabel
            
            textField.bindTextDidChange(to: viewStore) { text in
                .didUpdate(field, text)
            }
            viewStore.observeState(field.stateKey) { value in
                textField.text = value.value
                errorLabel.text = value.error ?? " "
            }
        }
        
        let button = UIButton(standardButtonWithTitle: "Register")
        
        view.addSubview(button)
        
        button.layout
            .below(last, offset: 30)
            .fillWidth(of: .safeArea, inset: 20, maximum: 300)
        
        button.bind(to: viewStore, action: .didTapSignup)
        
        viewStore.observeState(\.formIsValid) { [weak button] isValid in
            button?.isEnabled = isValid
        }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.layout
            .below(button, offset: 30)
            .centerX(to: .safeArea)
        
        viewStore.observeState(\.phase) { [weak self] phase in
            if phase == .working {
                self?.activityIndicator.startAnimating()
            }
            else {
                self?.activityIndicator.stopAnimating()
            }
            self?.view.isUserInteractionEnabled = phase != .working
        }
    }
    
    private func makeFormFieldAndLabel(for field: SignupForm.Field) -> (UITextField, UILabel) {
        let textField = UITextField(placeholder: field.label,
                                    autocapitalize: (field == .name) ? .words : .none)
        textField.isSecureTextEntry = field == .password
        
        let errorLabel = UILabel()
        errorLabel.textColor = .red
        errorLabel.numberOfLines = 1
        
        return (textField, errorLabel)
    }
}
