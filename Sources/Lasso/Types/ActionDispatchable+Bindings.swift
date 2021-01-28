//
// ==----------------------------------------------------------------------== //
//
//  ActionDispatchable+Bindings.swift
//
//
//  Helpers for binding various UIKit elements to Store Actions.
//
//  Created by Steven Grosmark on 6/5/19.
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

extension UIControl {
    
    /// Bind a UIControl event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - event: The UIControl.Event that will trigger the dispatchAction call on the target.
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - action: An ActionDispatchable.Action to send to the target via its `dispatchAction` method.
    public func bind<Target: ActionDispatchable>(_ event: UIControl.Event = .touchUpInside, to target: Target, action: Target.Action) {
        bind(event, to: target) { _ in return action }
    }

}

extension UIPageControl {
    
    /// Bind the UIPageControl's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the `currentPage` value to an ActionDispatchable.Action to be dispatched to the target.
    ///   - currentPage: the new `currentPage` value.
    public func bindValueChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ currentPage: Int) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0.currentPage) }
    }
    
}

extension UISegmentedControl {
    
    /// Bind the UISegmentedControl's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the `selectedSegmentIndex` value to an ActionDispatchable.Action to be dispatched to the target.
    ///   - selectedIndex: the new `selectedSegmentIndex` value.
    public func bindValueChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ selectedIndex: Int) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0.selectedSegmentIndex) }
    }
    
}

extension UISlider {
    
    /// Bind the UISlider's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the slider `value` to an ActionDispatchable.Action to be dispatched to the target.
    ///   - newValue: the new `value`.
    public func bindValueChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ newValue: Float) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0.value) }
    }
    
}

extension UISwitch {
    
    /// Bind the UISwitch's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the `isOn` value to an ActionDispatchable.Action to be dispatched to the target.
    ///   - isOn: the new `isOn` value.
    public func bindValueChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ isOn: Bool) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0.isOn) }
    }
    
}

extension UIStepper {
    
    /// Bind the UIStepper's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the stepper `value` to an ActionDispatchable.Action to be dispatched to the target.
    ///   - newValue: the new stepper `value`.
    public func bindValueChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ newValue: Double) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0.value) }
    }
    
}

extension UIDatePicker {
    
    /// Bind a UIDatePicker's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    /// Use when the UIDatePicker's mode is `date`, `time`, or `dateAndTime`.
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the `date` value to an ActionDispatchable.Action to be dispatched to the target.
    ///   - date: the picker's new `date` value.
    public func bindDateChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ date: Date) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0.date) }
    }
    
    /// Bind a UIDatePicker's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    /// Use when the UIDatePicker's mode is `countDownTimer`.
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the `countDownDuration` value to an ActionDispatchable.Action to be dispatched to the target.
    ///   - countDownDuration: the picker's new `countDownDuration` value.
    public func bindDurationChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ countDownDuration: TimeInterval) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0.countDownDuration) }
    }
    
    /// Bind the UIDatePicker's `.valueChanged` event to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the UIDatePicker to an ActionDispatchable.Action to be dispatched to the target.
    ///   - datePicker: the UIDatePicker triggering the event.
    public func bindValueChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ datePicker: UIDatePicker) -> Target.Action) {
        bind(.valueChanged, to: target) { mapping($0) }
    }
    
}

public protocol ControlActionBindable where Self: UIControl { }

extension UIControl: ControlActionBindable { }

extension ControlActionBindable {
    
    /// Bind a UIControl event to an ActionDispatchable where the Action is a function of the control at the time of invocation.
    ///
    /// - Parameters:
    ///   - event: The UIControl.Event that will trigger the action.
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the control's current state to an ActionDispatchable.Action to be dispatched to the target.
    ///   - sender: The control
    public func bind<Target: ActionDispatchable>(_ event: UIControl.Event = .touchUpInside,
                                                 to target: Target,
                                                 mapping: @escaping (_ sender: Self) -> Target.Action) {
        let eventHandler = EventHandler { [weak self, weak target] in
            self.map { target?.dispatchAction(mapping($0)) }
        }
        addTarget(eventHandler, action: #selector(eventHandler.execute), for: event)
        holdReference(to: eventHandler)
    }
    
}

// MARK: - Bar button item action binding

extension UIBarButtonItem {
    
    public convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
    }
    
    public convenience init(image: UIImage?, style: UIBarButtonItem.Style = .plain) {
        self.init(image: image, style: style, target: nil, action: nil)
    }
    
    public convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItem.Style = .plain) {
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)
    }
    
    public convenience init(title: String?, style: UIBarButtonItem.Style = .plain) {
        self.init(title: title, style: style, target: nil, action: nil)
    }
    
    /// Bind a bar button item's action to an ActionDispatchable (a.k.a. Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - toAction: A Store.Action to send to the target via its `dispatchAction` method.
    public func bind<Target: ActionDispatchable>(to target: Target, action: Target.Action) {
        bind(to: target) { _ in return action }
    }
    
    /// Bind a UIBarButtonItem event to an ActionDispatchable where the Action is a function of the item at the time of invocation.
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the button tap to an ActionDispatchable.Action to be dispatched to the target.
    ///   - sender: The UIBarButtonItem triggering the action
    public func bind<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ sender: UIBarButtonItem) -> Target.Action) {
        let eventHandler = EventHandler { [weak self, weak target] in
            self.map { target?.dispatchAction(mapping($0)) }
        }
        self.target = eventHandler
        self.action = #selector(eventHandler.execute)
        holdReference(to: eventHandler)
    }
    
}

// MARK: - Gesture recognizer action binding

extension UIGestureRecognizer {
    
    /// Bind a gesture recognizer's action to an ActionDispatchable (a.k.a. Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - toAction: A Store.Action to send to the target via its `dispatchAction` method.
    public func bind<Target: ActionDispatchable>(to target: Target, action: Target.Action) {
        bind(to: target) { _ in return action }
    }
    
}

public protocol GestureActionBindable: UIGestureRecognizer { }

extension UIGestureRecognizer: GestureActionBindable { }

extension GestureActionBindable {
    
    /// Bind a UIGestureRecognizer event to an ActionDispatchable where the Action is a function of the gesture recognizer at the time of invocation.
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the gesture recognizer's current state to an ActionDispatchable.Action to be dispatched to the target.
    ///   - sender: The UIGestureRecognizer triggering the action
    public func bind<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ sender: Self) -> Target.Action) {
        let eventHandler = EventHandler { [weak self, weak target] in
            self.map { target?.dispatchAction(mapping($0)) }
        }
        addTarget(eventHandler, action: #selector(eventHandler.execute))
        holdReference(to: eventHandler)
    }
}

// MARK: - Text change notification binding

extension UITextField {
    
    /// Bind the UITextField's `didChange` notification to dispatch an Action to an ActionDispatchable (a.k.a Store).
    ///
    /// - Parameters:
    ///   - target: The ActionDispatchable to receive the Action.
    ///   - mapping: A function that maps the `text` value to an ActionDispatchable.Action to be dispatched to the target.
    ///   - newText: The updated text.
    public func bindTextDidChange<Target: ActionDispatchable>(to target: Target, mapping: @escaping (_ newText: String) -> Target.Action) {
        bind(UITextField.textDidChangeNotification) { [weak self, weak target] _ in
            self.map { target?.dispatchAction(mapping($0.text ?? "")) }
        }
    }
    
    private func bind(_ notificationName: NSNotification.Name, to handler: @escaping (Notification) -> Void) {
        let observer = NotificationObserver(self, notificationName, handler)
        holdReference(to: observer)
    }
    
}

/// Helper to wrap the @obj aspect of listening to a notification
private class NotificationObserver {
    
    init(_ object: AnyObject, _ notificationName: NSNotification.Name, _ handler: @escaping (Notification) -> Void) {
        self.observation = NotificationCenter.default.addObserver(forName: notificationName, object: object, queue: .main) { [weak object] notification in
            if object != nil { handler(notification) }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observation)
    }
    
    let observation: NSObjectProtocol
}

/// Helper to wrap the `@obj` aspect of UIKit action handling
private class EventHandler {
    
    init(_ execute: @escaping () -> Void) {
        self._execute = execute
    }
    
    @objc func execute() {
        _execute()
    }
    
    let _execute: () -> Void
}
