//
// ==----------------------------------------------------------------------== //
//
//  SimpleCounter.swift
//
//  Created by Steven Grosmark on 6/16/19.
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
#if canImport(SwiftUI) && swift(>=5.1)
    import SwiftUI
#endif
import Lasso
import WWLayout

enum SimpleCounter: ScreenModule {
    
    enum Action: Equatable {
        case didTapIncrement
        case didTapDecrement
    }
    
    struct State: Equatable {
        var count: Int = 0
    }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: SimpleCounterStore) -> Screen {
        // test if compiling with Xcode 11
        #if canImport(SwiftUI) && swift(>=5.1)
            // test if running on iOS 13
            if #available(iOS 13.0, *) {
                let view = SwiftUICounterView(store: store.asBindableViewStore())
                return Screen(store, view)
            }
        #endif
        let controller = SimpleCounterViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
}

class SimpleCounterStore: LassoStore<SimpleCounter> {
    
    override func handleAction(_ action: Action) {
        switch action {
            
        case .didTapIncrement:
            update { state in
                state.count += 1
            }
            
        case .didTapDecrement:
            update { state in
                state.count = max(state.count - 1, 0)
            }
        }
    }
}

class SimpleCounterViewController: UIViewController, LassoView {
    
    let store: SimpleCounter.ViewStore
    
    init(store: SimpleCounter.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        let title = UILabel()
        title.text = "UIKit Simple Counter"
        
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 64, weight: .bold)
        label.textAlignment = .center
        label.backgroundColor = UIColor.yellow.withAlphaComponent(0.25)
        label.set(cornerRadius: 11)
        
        let incButton = UIButton(standardButtonWithTitle: "+1")
        let decButton = UIButton(standardButtonWithTitle: "-1")
        
        view.addSubviews(title, label, incButton, decButton)
        
        title.layout
            .bottom(to: label, edge: .top, offset: -20)
            .centerX(to: .safeArea)
        
        label.layout
            .center(in: .safeArea)
            .size(200, 200)
        
        incButton.layout
            .below(label, offset: 20)
            .right(to: label)
            .width(90)
        decButton.layout
            .below(label, offset: 20)
            .left(to: label)
            .width(90)
        
        store.observeState(\.count) { [weak label] count in
            label?.text = "\(count)"
        }
        
        incButton.bind(to: store, action: .didTapIncrement)
        decButton.bind(to: store, action: .didTapDecrement)
    }
}

// MARK: - SwiftUI version
#if canImport(SwiftUI) && swift(>=5.1)

@available(iOS 13.0, *)
struct SwiftUICounterView: View {
    
    @ObservedObject private var store: SimpleCounter.BindableViewStore
    
    init(store: SimpleCounter.BindableViewStore) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Text("SwiftUI Simple Counter")
            Text("\(store.state.count)")
                .font(.largeTitle)
                .scaledToFill()
                .frame(width: 200, height: 200)
                .background(Color.yellow.opacity(0.5))
                .cornerRadius(11)
            
            HStack(spacing: 20) {
                Button(store, action: .didTapDecrement) {
                    ButtonLabel("-1")
                }
                Button(store, action: .didTapIncrement) {
                    ButtonLabel("+1")
                }
            }
        }
        .padding()
    }
    
}

@available(iOS 13.0, *)
struct ButtonLabel: View {
    
    var label: String
    
    init(_ label: String) {
        self.label = label
    }
    
    var body: some View {
        Text(label)
            .padding(10)
            .frame(width: 90)
            .foregroundColor(.white)
            .background(Color(red: 0.2, green: 0, blue: 1.0, opacity: 0.5))
            .cornerRadius(5)
    }
    
}

#endif
