//
//===----------------------------------------------------------------------===//
//
//  SignupIntro.swift
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

enum SignupIntro: ScreenModule {
    
    static func createScreen(with store: IntroStore) -> Screen {
        let controller = SignupIntroViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
    enum Action: Equatable {
        case didTapNext
    }
    
    typealias Output = Action
    
    class IntroStore: LassoStore<SignupIntro> {
        override func handleAction(_ action: Action) {
            dispatchOutput(action)
        }
    }
    
}

class SignupIntroViewController: UIViewController, LassoView {
    
    let store: SignupIntro.ViewStore
    
    init(store: SignupIntro.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        let label = UILabel(body: "Please sign up for our delightful experience.")
        let button = UIButton(standardButtonWithTitle: "Begin")
        
        view.addSubviews(label, button)
        
        label.layout
            .fill(.safeArea, except: .bottom, inset: 30)
            .height(to: .safeArea, multiplier: 0.5)
        button.layout
            .below(label, offset: 20)
            .fillWidth(of: .safeArea, inset: 30, maximum: 300)
        
        button.bind(to: store, action: .didTapNext)
    }
}
