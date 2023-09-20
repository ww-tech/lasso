//
// ==----------------------------------------------------------------------== //
//
//  Flow.swift
//
//  Created by Steven Grosmark on 4/15/19.
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

/// A sequence of screens which can be started in the RequiredContext.
///
/// The typical Flow creation cycle is
/// ```swift
///     let flow = Flow()
///     flow.start(with: ScreenPlacer<RequiredContext>)
/// ```
/// Optionally, you can observe the output of a flow:
///     flow.observeOutput { [weak self] output in /* do something /* }
open class Flow<Module: FlowModule> {
    
    public typealias Output = Module.Output
    public typealias RequiredContext = Module.RequiredContext
    
    public private(set) weak var context: RequiredContext?
    public private(set) weak var initialController: UIViewController?
    
    public init() {
    }
    
    /// Starts the flow
    ///
    /// Places the controller returned by 'createInitialController' with the provided placer.
    /// Handles ARC considerations relative to the Flow, creating a strong reference from
    /// the initial controller to the Flow.
    ///
    /// - Parameter placer: ScreenPlacer with 'placedContext' that is compatible with the Flow's 'RequiredContext'
    public func start(with placer: ScreenPlacer<RequiredContext>?) {
        lassoPrecondition(placer != nil, "\(self).start(with: placer) placer is nil!")
        guard let placer = placer else { return }
        
        let initialController = createInitialController()
        
        initialController.holdReference(to: self)
        
        self.context = initialController.place(with: placer)
        self.initialController = initialController
    }
    
    /// Creates the initial view controller for the Flow.
    ///
    /// Do not call this directly, instead use the `start` function.
    open func createInitialController() -> UIViewController {
        return lassoAbstractMethod()
    }
    
    @discardableResult
    public func observeOutput(_ handler: @escaping @Sendable (Output) async -> Void) -> Self {
        Task {
            await outputBridge.register(handler)
        }
        return self
    }
    
    // Convenience for simple mapping from the Screen's Output type to another OtherOutput type
    //  - so callers don't have to create a closure do perform simple mapping.
    @discardableResult
    public func observeOutput<OtherOutput>(_ handler: @escaping @Sendable (OtherOutput) async -> Void, mapping: @escaping @Sendable (Output) -> OtherOutput) -> Self {
        observeOutput { output in
            await handler(mapping(output))
        }
        return self
    }
    
    public func dispatchOutput(_ output: Output) {
        Task {
            await outputBridge.dispatch(output)
        }
    }
    
    private let outputBridge = OutputBridge<Output>()
}
