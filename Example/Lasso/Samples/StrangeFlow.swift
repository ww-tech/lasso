//
// ==----------------------------------------------------------------------== //
//
//  StrangeFlow.swift
//
//  Created by Steven Grosmark on 5/20/19.
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

class StrangeFlow: Flow<NoOutputNavigationFlow> {
    
    override func createInitialController() -> UIViewController {
        let state = TextScreenModule.State(title: "My Day", description: "Tap \"Track\" to track something.", buttons: ["Track"])
        return TextScreenModule.createScreen(with: state)
                .observeOutput { [weak self] in self?.handleScreenOutput(.myday($0)) }
                .controller
    }
    
    private func handleScreenOutput(_ output: ScreenOutput) {
        switch output {
            
        case .myday(.didTapButton):
            let state = TextScreenModule.State(title: "Track Something", buttons: ["Food", "Weight", "Activity"])
            TextScreenModule.createScreen(with: state)
                .observeOutput { [weak self] in self?.handleScreenOutput(.trackMenu($0)) }
                .captureController(as: &trackSomethingController)
                .place(with: nextPresentedInFlow?.withDismissibleNavigationEmbedding())
            
        case .trackMenu(.didTapButton(let index)):
            guard let navigationController = context else { return }
            let thing = ["Food", "Weight", "Activity"][index]
            let state = TextScreenModule.State(title: "Track \(thing)", description: "Tap \"Track\" to track a \(thing).", buttons: ["Track \(thing)"])
            
            let strangePlacer = makePlacer(base: navigationController) { (navigationController, toPlace) -> UINavigationController in
                navigationController.pushViewController(toPlace, animated: true)
                self.trackSomethingController?.dismiss(animated: true)
                return navigationController
            }
            TextScreenModule.createScreen(with: state)
                .observeOutput { [weak self] in self?.handleScreenOutput(.track($0)) }
                .place(with: strangePlacer)
            
        case .track(.didTapButton):
            initialController?.navigationController?.popViewController(animated: true)
        }
    }
    
    enum ScreenOutput {
        case myday(TextScreenModule.Output)
        case trackMenu(TextScreenModule.Output)
        case track(TextScreenModule.Output)
    }
    
    private weak var trackSomethingController: UIViewController?
    
}
