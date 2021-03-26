//
// ==----------------------------------------------------------------------== //
//
//  ButtonStyle+App.swift
//
//  Created by Steven Grosmark on 03/24/2021.
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

struct RowStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(
                (configuration.isPressed ? Color(white: 0.9, opacity: 1.0) : Color.white)
                    .padding(EdgeInsets(top: -12, leading: -20, bottom: -12, trailing: -20)) // magic number alert!
            )
        
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    
    private let maxWidth: CGFloat
    private let innerPadding: EdgeInsets
    
    init(maxWidth: CGFloat = 320, innerPadding: EdgeInsets = EdgeInsets(10)) {
        self.maxWidth = maxWidth
        self.innerPadding = innerPadding
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        MyButton(configuration: configuration, maxWidth: maxWidth, innerPadding: innerPadding)
    }
    
    private struct MyButton: View {
        let configuration: ButtonStyle.Configuration
        let maxWidth: CGFloat
        let innerPadding: EdgeInsets
        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            configuration.label
                .font(.headline)
                .padding(innerPadding)
                .frame(maxWidth: maxWidth)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.buttonForeground)
                .background(
                    background(isEnabled, configuration.isPressed)
                        .cornerRadius(5)
                )
        }
        
        private func background(_ isEnabled: Bool, _ isPressed: Bool) -> Color {
            if !isEnabled {
                return Color.buttonDisabledBackground
            }
            return isPressed ? Color.buttonPressedBackground : Color.buttonBackground
        }
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("buttons")
            
            Color.blue.frame(width: 200, height: 4, alignment: .center)
            Button("Primary Button (200pt)", action: { })
                .buttonStyle(PrimaryButtonStyle(maxWidth: 200))
            
            Color.blue.frame(width: 320, height: 4, alignment: .center)
            Button("Primary Button Primary Button Primary Button Primary Button (default maxWidth)", action: { })
                .buttonStyle(PrimaryButtonStyle())
            
            Button("Primary Button Primary Button Primary Button Primary Button (∞)", action: { })
                .buttonStyle(PrimaryButtonStyle(maxWidth: .infinity))
            
            Color.blue.frame(width: 200, height: 4, alignment: .center)
            Button("Disabled Primary Button", action: { })
                .disabled(true)
                .buttonStyle(PrimaryButtonStyle())
        }
//        .previewLayout(.fixed(width: 320, height: 480))
//        .previewDevice("iPhone SE (2nd generation)")
//        .previewDevice("iPhone 8")
//        .previewDevice("iPhone 12 Pro Max")
    }
}
