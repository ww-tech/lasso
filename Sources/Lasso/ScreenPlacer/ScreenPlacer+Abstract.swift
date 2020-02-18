//
//===----------------------------------------------------------------------===//
//
//  ScreenPlacer+Abstract.swift
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
//===----------------------------------------------------------------------===//
//

import UIKit

// Embodiment of the supported ScreenPlacer structures. Clients can call these utilities to make custom ScreenPlacers.
// B/c the init on ScreenPlacer is not publicly exposed, these utilities represent the only paths
// through which clients can create custom ScreenPlacers.
// MARK: - Instance Placement

/// Place some UIViewController relative to some Base artifact.
///
/// Choosing the appropriate NextContext is up to the discretion of the implementer. Intuitively, the NextContext
/// should reflect some artifact which allows placement of some 'next controller' in a position 'immediately tangent'
/// to the originally placed controller. By following this rule, one can place a sequence of screens in a reasonable way.
///
/// - Parameters:
///   - base: any object into which the controller can be placed
///   - place: a closure which executes the placement of the controller relative to the base
/// - Returns: the logical 'next' screen context
public func makePlacer<Base: AnyObject, NextContext: UIViewController>(base: Base,
                                                                       place: @escaping (Base, UIViewController) -> NextContext) -> ScreenPlacer<NextContext> {
    
    return ScreenPlacer<NextContext> { toPlace in
        return place(base, toPlace)
    }
}

// MARK: - Embedding
//
// ScreenPlacers are composable with respect to embeddings - any placer instance can be embedded. To embed is simply to
// to say "you're actually going place this container controller, and I'm going to place controller(s) in that container".
// All embeddings are deferred - the container is not placed until all requisite children of that container are placed.
// Embedding placers are required (by definition) to return the container as the PlacedContext. This is intuitively
// pleasing - the next logical target for placement following placement into a container is some other placement into that container.
// In this way, the container is a sort of persistent context with respect to embedding placers.

/// Make a ScreenPlacer which places a child controller into a container.
///
/// - Parameters:
///   - embedder: the container
///   - place: a closure which executes the placement of the child into the container
///   - onDidPlaceEmbedded: a closure to be executed immediately following placement of the child into the container
/// - Returns: a ScreenPlacer which places the child into the container
public func makeEmbeddingPlacer<Embedder: UIViewController>(into embedder: Embedder,
                                                            place: @escaping (Embedder, UIViewController) -> Void,
                                                            onDidPlaceEmbedded: @escaping () -> Void = { }) -> ScreenPlacer<Embedder> {
    
    return ScreenPlacer<Embedder> { toPlace in
        place(embedder, toPlace)
        onDidPlaceEmbedded()
        return embedder
    }
}

/// Make many ScreenPlacers which each place a child controller into the embedding container.
///
/// Placement of the many children into the container is deferred until all children have been placed.
/// Failure to place all children will result in the container never being placed.
///
/// - Parameters:
///   - embedder: the container
///   - count: the number of children which need to be placed into the container
///   - place: a closure which executes the placement of the many children into the container
///   - onDidPlaceEmbedded: a closure to be executed immediately following placement of the many children into the container
/// - Returns: many ScreenPlacers which each place a child into the container
public func makeEmbeddingPlacers<Embedder: UIViewController>(into embedder: Embedder,
                                                             count: Int,
                                                             place: @escaping (Embedder, [UIViewController]) -> Void,
                                                             onDidPlaceEmbedded: @escaping () -> Void = { }) -> [ScreenPlacer<Embedder>] {
    
    var buffer = [UIViewController?](repeating: nil, count: count) {
        didSet {
            let embedded = buffer.compactMap({ $0 })
            guard embedded.count == count else { return }
            place(embedder, embedded)
            onDidPlaceEmbedded()
        }
    }
    
    return (0..<count).map({ i in
        return ScreenPlacer<Embedder> { toPlace in
            buffer[i] = toPlace
            return embedder
        }
    })
}

extension ScreenPlacer {
    
    /// Compose a singular embedding into an existing placer.
    ///
    /// - Parameters:
    ///   - embedder: the container
    ///   - place: a closure which executes the placement of the child into the container
    /// - Returns: a ScreenPlacer which places the child into the container
    public func withEmbedding<Embedder: UIViewController>(into embedder: Embedder,
                                                          place: @escaping (Embedder, UIViewController) -> Void) -> ScreenPlacer<Embedder> {
        
        return makeEmbeddingPlacer(into: embedder, place: place) {
            self.place(embedder)
        }
    }
    
    /// Compose a plural embedding into an existing placer.
    ///
    /// - Parameters:
    ///   - embedder: the container
    ///   - count: the number of children which need to be placed into the container
    ///   - place: a closure which executes the placement of the many children into the container
    /// - Returns: many ScreenPlacers which each place a child into the container
    public func withEmbedding<Embedder: UIViewController>(into embedder: Embedder,
                                                          count: Int,
                                                          place: @escaping (Embedder, [UIViewController]) -> Void) -> [ScreenPlacer<Embedder>] {
        
        return makeEmbeddingPlacers(into: embedder, count: count, place: place) {
            self.place(embedder)
        }
    }
    
}
