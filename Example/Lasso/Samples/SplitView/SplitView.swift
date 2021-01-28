//
// ==----------------------------------------------------------------------== //
//
//  SplitView.swift
//
//  Created by Steven Grosmark on 5/26/19.
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

enum SplitViewFlowModule: FlowModule {
    
    enum Output: Equatable {
        case didPressDone
    }
    
    typealias RequiredContext = UIViewController
    
    enum Option {
        case lessDetail
        case moreDetail
    }
    
}

class SplitViewFlow: Flow<SplitViewFlowModule>, UISplitViewControllerDelegate {
    
    // This switch dictates what the SplitViewFlow will place as its 'detail' controller.
    //
    //   lessDetail -> place a screen embedded in a nav controller; add the 'expand' button
    //                 to that nav controller
    //
    //   moreDetail -> place a flow which supports a sequence of screens embedded in a nav controller
    //
    private let option: SplitViewFlowModule.Option
    private weak var splitController: UISplitViewController?
    private var didSelectItem = false
    
    init(option: SplitViewFlowModule.Option = .lessDetail) {
        self.option = option
        super.init()
    }
    
    override func createInitialController() -> UIViewController {
        
        let splitController = UISplitViewController()
        splitController.preferredDisplayMode = .allVisible
        splitController.delegate = self
        
        let primaryNavigationController = UINavigationController(rootViewController: assemblePrimaryScreen().controller)
        let emptyController = UIViewController()
        emptyController.view.backgroundColor = .background
        let detailNavigationController = UINavigationController(rootViewController: emptyController)
        splitController.viewControllers = [primaryNavigationController, detailNavigationController]
        
        self.splitController = splitController
        return splitController
    }
    
    private func assemblePrimaryScreen() -> RandomItems.Screen {
        
        return RandomItems.createScreen()
            .observeOutput({ [weak self] output in
                switch output {
                    
                case .didSelectItem(let item):
                    self?.didSelectItem = true
                    self?.showItem(item)
                }
            })
            .setUpController({
                $0.title = "Random Items"
                let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDone))
                $0.navigationItem.leftBarButtonItem = button
            })
    }
    
    @objc private func didPressDone() {
        dispatchOutput(.didPressDone)
    }
    
    private func showItem(_ item: RandomItems.Item) {
        
        guard let splitController = splitController else { return }
        let itemController: UIViewController
        
        switch option {
            
        case .lessDetail:
            let screen = TextScreenModule.createScreen(with: item.asTextState)
                .setUpController({
                    $0.title = item.name
                    $0.navigationItem.leftBarButtonItem = splitController.displayModeButtonItem
                    $0.navigationItem.leftItemsSupplementBackButton = true
                })
            
            itemController = UINavigationController(rootViewController: screen.controller)
            
        case .moreDetail:
            let navigationController = UINavigationController()
            RandomItemFlow(for: item).start(with: root(of: navigationController))
            itemController = navigationController
        }
        
        splitController.showDetailViewController(itemController, sender: nil)
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return !didSelectItem
    }
    
}

extension RandomItems.Item {
    
    fileprivate var asTextState: TextScreenModule.State {
        return TextScreenModule.State(title: name, description: description)
    }
    
}
