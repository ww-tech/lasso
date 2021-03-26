//
// ==----------------------------------------------------------------------== //
//
//  LoginView.swift
//
//  Created by Steven Grosmark on 03/26/2021
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

import SwiftUI
import Lasso

extension LassoView where Self: View {
}

struct LoginView: View, LassoView {
    
    @ObservedObject var store: Login.ViewStore
    
    init(store: Login.ViewStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding()
            
            TextField(
                "username",
                boundTo: store,
                text: \.username,
                action: Login.Action.didEditUsername
            )
            .disableAutocorrection(true)
            .autocapitalization(.none)
            
            SecureField(
                "password",
                text: store.binding(\.password, action: Login.Action.didEditPassword)
            )
            .disableAutocorrection(true)
            .autocapitalization(.none)
            
            Button("Login", target: store, action: .didTapLogin)
                .disabled(!store.state.canLogin)
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
            
            VStack {
                Color.clear.frame(height: 10) // keeps the VStack from collapsing
                if let error = state.error {
                    Text(error)
                        .foregroundColor(.red)
                }
                if state.phase == .busy {
                    ActivityIndicator()
                }
            }
            .frame(height: 100, alignment: .top)
        }
        .frame(alignment: .top)
        .textFieldStyle(PrimaryTextFieldStyle())
        .buttonStyle(PrimaryButtonStyle())
        .padding()
        .frame(maxWidth: 300)
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let store = LoginStore(with: Login.defaultInitialState)
        LoginView(store: store.asViewStore())
    }
}
