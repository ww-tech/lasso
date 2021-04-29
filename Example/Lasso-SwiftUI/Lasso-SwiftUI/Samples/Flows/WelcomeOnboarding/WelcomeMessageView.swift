//
// ==----------------------------------------------------------------------== //
//
//  WelcomeMessageView.swift
//
//  Created by Steven Grosmark on 03/25/2021
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

struct WelcomeMessageView: View {
    
    @ObservedObject private var store: WelcomeMessage.ViewStore
    
    init(store: WelcomeMessage.ViewStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(store.state.text)
                .font(.largeTitle)
                .padding()
            
            Spacer()
            Button("Next", target: store, action: .didTapNext)
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

}

struct WelcomeMessageView_Previews: PreviewProvider {
    static var previews: some View {
        let store = WelcomeMessage.ConcreteStore(with: WelcomeMessage.defaultInitialState)
        WelcomeMessageView(store: store.asViewStore())
    }
}
