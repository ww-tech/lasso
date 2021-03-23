//
// ==----------------------------------------------------------------------== //
//
//  MyDayFlow.swift
//
//  Created by Trevor Beasty on 10/21/19.
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
import Lasso

class MyDayFlow: Flow<NoOutputNavigationFlow> {
    
    var createMyDay = MyDayController.init(date:)
    
    private let initialDate: Date
    
    init(date: Date = Date()) {
        self.initialDate = date
    }
    
    override func createInitialController() -> UIViewController {
        return assembleMyDayController()
    }
    
    private func assembleMyDayController() -> UIViewController {
        let myDay = createMyDay(initialDate)
        
        myDay.cardsScreen.store.observeOutput { [weak self] (output) in
            guard let self = self else { return }
            switch output {
                
            case .didSelectCard(card: let card):
                let cardController = self.assembleCardController(card: card)
                self.context?.pushViewController(cardController, animated: true)
            }
        }
        
        return myDay
    }
    
    private func assembleCardController(card: String) -> UIViewController {
        let state = TextScreenModule.State(title: card, description: "Blah blah, blah blah")
        return TextScreenModule.createScreen(with: state)
            .controller
    }
}
