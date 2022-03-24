//
// ==----------------------------------------------------------------------== //
//
//  SimpleCounterView.swift
//
//  Created by Steven Grosmark on 03/25/2021.
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

struct SimpleCounterView: View {
    
    @ObservedObject private var store: SimpleCounter.ViewStore
    
    init(store: SimpleCounter.ViewStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Text("How many?")
                .padding()
            
            Text("\(store.state.count)")
                .font(.largeTitle)
                .scaledToFill()
                .frame(width: 260, height: 200)
                .background(Color.gray.opacity(0.25))
                .cornerRadius(11)
                .padding()
            
            HStack(spacing: 20) {
                Button("-1", target: store, action: .didTapDecrement)
                Button("+1", target: store, action: .didTapIncrement)
            }
            .frame(width: 260)
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
    
}

struct SimpleCounterView_Previews: PreviewProvider {
    static var previews: some View {
        let store = SimpleCounterStore(with: SimpleCounter.defaultInitialState)
        SimpleCounterView(store: store.asViewStore())
    }
}
