//
// ==----------------------------------------------------------------------== //
//
//  ScreenPlacer.swift
//
//  Created by Trevor Beasty on 5/30/19.
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

/// An ephemeral object which places a controller into the view controller hierarchy. Upon placement, the caller is given
/// the resulting context - the environment into which the controller has been placed.
///
/// The ScreenPlacer client needs:
///   - to be able to place a view controller into the view controller hierarchy
///   - to be able to effect changes in the view controller hierarchy following initial controller placement
///
/// The ScreenPlacer client does not care about:
///   - artifacts of the view controller hierarchy preceding the immediate, placed context
///
/// Thus, the ScreenPlacer 'erases' the previous context. This allows us to implement controller sequences that are
/// modular with respect to the view controller hierarchy.
///
/// ScreenPlacers retain strong references to their dependent controllers. Retaining a ScreenPlacer will retain those dependent controllers.
///
/// Any ScreenPlacer instance will only place once. Any further call to 'place' will simply return the PlacedContext without creating any side
/// effects in the existing view controller hierarchy.
///
public class ScreenPlacer<PlacedContext: UIViewController> {
    internal typealias Place = (UIViewController) -> PlacedContext
    
    private let _place: Place
    private var placedContext: PlacedContext?
    
    internal init(place: @escaping Place) {
        self._place = place
    }
    
    /// Place a controller into the view controller hierarchy.
    ///
    /// - Parameter viewController: the view controller to be placed
    /// - Returns: the context into which the view controller was placed
    @discardableResult
    public func place(_ viewController: UIViewController) -> PlacedContext {
        /// Silently fail if a client attempts to place twice.
        lassoPrecondition(placedContext == nil, "multiple placements attempted; ScreenPlacers may only place once")
        if let placedContext = self.placedContext {
            return placedContext
        }
        let placedContext = _place(viewController)
        self.placedContext = placedContext
        return placedContext
    }
    
}

extension UIViewController {
    
    /// Place a controller into the view controller hierarchy.
    ///
    /// - Parameter placer: some ScreenPlacer
    /// - Returns: the context into which the view controller was placed
    @discardableResult
    public func place<PlacedContext: UIViewController>(with placer: ScreenPlacer<PlacedContext>?) -> PlacedContext? {
        lassoPrecondition(placer != nil, "attempt to place \(type(of: self)) with nil placer")
        return placer?.place(self)
    }
    
}
