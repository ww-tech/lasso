//
// ==----------------------------------------------------------------------== //
//
//  Flow+UIPageViewController.swift
//
//  Created by Trevor Beasty on 6/12/19.
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

public extension Flow where RequiredContext: UIPageViewController {
    
    /// Set as the page controller's page with a forward animation.
    var nextPageInFlow: ScreenPlacer<RequiredContext>? {
        guard let pageController = context else { return nil }
        return nextPage(in: pageController)
    }
    
}
