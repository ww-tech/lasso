//
// ==----------------------------------------------------------------------== //
//
//  ActivityIndicator.swift
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

import UIKit
import SwiftUI

struct ActivityIndicator: View {
    
    @State var isAnimating: Bool = true
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ProgressView().progressViewStyle(CircularProgressViewStyle())
        }
        else {
            UIKitActivityIndicator(isAnimating: $isAnimating, style: .medium)
        }
    }
    
    private struct UIKitActivityIndicator: UIViewRepresentable {
        
        @Binding var isAnimating: Bool
        let style: UIActivityIndicatorView.Style
        
        func makeUIView(context: UIViewRepresentableContext<UIKitActivityIndicator>) -> UIActivityIndicatorView {
            let indicator = UIActivityIndicatorView(style: style)
            indicator.hidesWhenStopped = false
            return indicator
        }
        
        func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<UIKitActivityIndicator>) {
            if isAnimating {
                uiView.startAnimating()
            }
            else {
                uiView.stopAnimating()
            }
        }
    }
}
