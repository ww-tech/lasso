//
// ==----------------------------------------------------------------------== //
//
//  SwiftUIBinding.swift
//
//  Created by Steven Grosmark on 1/28/21
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

import Foundation

#if canImport(SwiftUI) && swift(>=5.1)
import UIKit
import SwiftUI
import Lasso
import WWLayout

@available(iOS 13.0, *)
enum SwiftUIBinding: ScreenModule {
    
    enum Action: Equatable {
        case didChangeName(String)
        case didChangeNumber(Int)
    }
    
    struct State: Equatable {
        var name: String = ""
        var number: Int = 0
    }
    
    static var defaultInitialState: State { State() }
    
    static func createScreen(with store: SwiftUIBindingStore) -> Screen {
        let view = SwiftUIBindingView(store: store.asBindableViewStore())
        return Screen(store, view)
    }
    
}

@available(iOS 13.0, *)
class SwiftUIBindingStore: LassoStore<SwiftUIBinding> {
    
    override func handleAction(_ action: Action) {
        switch action {
        
        case .didChangeName(let name):
            update { state in
                state.name = name
            }
            
        case .didChangeNumber(let number):
            update { state in
                state.number = number
            }
        }
    }
}

@available(iOS 13.0, *)
struct SwiftUIBindingView: View {
    
    @ObservedObject private var store: SwiftUIBinding.BindableViewStore
    @State var other: String = ""
    
    init(store: SwiftUIBinding.BindableViewStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            
            TextField("name", boundTo: store, text: \.name, action: SwiftUIBinding.Action.didChangeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Name", text: store.binding(\.name, actionMap: SwiftUIBinding.Action.didChangeName))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("Your name is: \(store.state.name)")
                .font(.caption)
            
            Divider()
            
            TextField("Other", text: $other)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("Your other name is: \(other)")
                .font(.caption)
            
            Divider()
            
            TextField(
                "Number",
                text: store.binding(
                    \.number,
                    valueMap: String.init,
                    actionMap: { SwiftUIBinding.Action.didChangeNumber(Int($0) ?? 0) }
                )
            )
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("Your number is: \(store.state.number)")
                .font(.caption)
        }
        .padding()
    }
    
}

#endif
