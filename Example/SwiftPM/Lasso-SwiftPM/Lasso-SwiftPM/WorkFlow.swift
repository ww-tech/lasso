//
//===----------------------------------------------------------------------===//
//
//  WorkFlow.swift
//
//  Created by Steven Grosmark on 1/6/20.
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
import Lasso

final class WorkFlow: Flow<NoOutputFlow> {
    
    var workStore: WorkScreenModule.Store?
    
    override func createInitialController() -> UIViewController {
        WorkScreenModule
            .createScreen()
            .captureStore(as: &workStore)
            .observeOutput { [weak self] output in
                switch output {
                    
                case .didWorkEnough:
                    self?.timeToRest()
                }
            }
            .controller
    }
    
    private func timeToRest() {
        RestScreenModule
            .createScreen()
            .observeOutput { [weak self] output in
                switch output {
                    
                case .didRestEnough:
                    self?.workStore?.dispatchAction(.didGetSomeRest)
                    self?.unwind()
                }
            }
            .place(with: nextPresentedInFlow)
    }
    
}
