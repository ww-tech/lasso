//
// ==----------------------------------------------------------------------== //
//
//  PageControllerFlow.swift
//
//  Created by Trevor Beasty on 12/3/19.
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

import Lasso

enum PageControllerFlowModule: FlowModule {
    
    typealias RequiredContext = UIPageViewController
    
    enum Output: Equatable {
        case didFinish
    }
    
}

class PageControllerFlow: Flow<PageControllerFlowModule> {
    
    override func createInitialController() -> UIViewController {
        return assembleController(0)
    }
    
    private func assembleController(_ order: Int) -> UIViewController {
        let state = TextScreenModule.State(title: "Screen \(order)", description: nil, buttons: order == 0 ? ["Next"] : ["Finish"])
        return TextScreenModule
            .createScreen(with: state)
            .observeOutput({ [weak self] output in
                guard let self = self, case .didTapButton = output else { return }
                switch order {
                    
                case 0:
                    let controller1 = self.assembleController(1)
                    // When controller1 is set on the pageController, the initial controller is deallocated. B/c the initial controller was
                    // the only object retaining this Flow, a new strong reference must be created from controller 1 to this Flow
                    controller1.holdReference(to: self)
                    controller1.place(with: self.nextPageInFlow)
                    
                case 1:
                    self.dispatchOutput(.didFinish)
                    
                default:
                    return
                }
            })
            .controller
    }
    
}
