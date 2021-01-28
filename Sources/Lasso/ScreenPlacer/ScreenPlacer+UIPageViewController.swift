//
// ==----------------------------------------------------------------------== //
//
//  ScreenPlacer+UIPageViewController.swift
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

// MARK: - Embedding

/// Place some controller as the single page of the page controller.
///
/// - Parameters:
///   - pageController: the page controller to be placed into
///   - onDidPlaceEmbedded: a closure to be executed immediately following placement of the child into the page controller
/// - Returns: the placer into the page controller
public func pageEmbedding(_ pageController: UIPageViewController = ScreenPlacerEmbedding.makePageController(),
                          onDidPlaceEmbedded: @escaping () -> Void = { }) -> ScreenPlacer<UIPageViewController> {
    
    let place = { (pageController: UIPageViewController, toPlace: UIViewController) in
        pageController.setViewControllers([toPlace], direction: .forward, animated: false, completion: nil)
    }
    
    return makeEmbeddingPlacer(into: pageController, place: place, onDidPlaceEmbedded: onDidPlaceEmbedded)
}

extension ScreenPlacer {
    
    /// Compose a page embedding into an existing placer.
    ///
    /// - Parameter pageController: the page controller to be placed into
    /// - Returns: the placer into the page controller
    public func withPageEmbedding(_ pageController: UIPageViewController = ScreenPlacerEmbedding.makePageController()) -> ScreenPlacer<UIPageViewController> {
        
        return pageEmbedding(pageController, onDidPlaceEmbedded: {
            self.place(pageController)
        })
    }
    
}
    
// MARK: Instance Placement

/// Set some controller as the single page of the page controller with a forward animation.
///
/// - Parameter pageController: the page controller to be placed into
/// - Returns: the placer into the page controller
public func nextPage<PageController: UIPageViewController>(in pageController: PageController, animated: Bool = true) -> ScreenPlacer<PageController> {
    
    return makePlacer(base: pageController, place: { (pageController, toPlace) -> PageController in
        pageController.setViewControllers([toPlace], direction: .forward, animated: animated, completion: nil)
        return pageController
    })
}
