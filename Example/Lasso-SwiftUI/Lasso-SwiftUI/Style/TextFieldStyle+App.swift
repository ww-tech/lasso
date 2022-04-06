//
// ==----------------------------------------------------------------------== //
//
//  TextFieldStyle+App.swift
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

struct PrimaryTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            .overlay(
                Color.gray.frame(height: 2),
                alignment: .bottom
            )
    }
}

struct PrimaryTextField_Previews: PreviewProvider {
    
    static var previews: some View { Preview() }
    
    struct Preview: View {
        @State var someText: String = ""
        var body: some View {
            VStack {
                Text("text fields")
                
                TextField("Enter text", text: $someText)
                    .textFieldStyle(PrimaryTextFieldStyle())
            }
            .frame(maxWidth: 300)
            .padding()
        }
    }
}
