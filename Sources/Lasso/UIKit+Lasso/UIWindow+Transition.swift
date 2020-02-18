//
//===----------------------------------------------------------------------===//
//
//  UIWindow+Transition.swift
//
//  Created by Steven Grosmark on 6/6/19.
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

extension UIWindow {
    
    /// Set a new rootViewController using a transition
    ///
    /// - Parameters:
    ///   - controller: the new rootViewController
    ///   - transition: the Transition to use
    public func setRootViewController(_ controller: UIViewController, with transition: Transition, completion: (() -> Void)? = nil) {
        
        // Plain transitions animate the opacity of the "behind" view controller using a minimum
        // opacity of 0.  This results in partially revealing a black background during the transition.
        var backgroundWindow: UIWindow?
        if let backgroundColorOpacity = transition.backgroundColorOpacity,
            let color = rootViewController?.view.backgroundColor ?? backgroundColor {
            backgroundWindow = UIWindow()
            backgroundWindow?.backgroundColor = color.withAlphaComponent(backgroundColorOpacity)
            backgroundWindow?.makeKeyAndVisible()
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if let backgroundWindow = backgroundWindow {
                backgroundWindow.removeFromSuperview()
            }
            completion?()
        }
        
        layer.add(transition.animation, forKey: kCATransition)
        rootViewController = controller
        makeKeyAndVisible()
        
        CATransaction.commit()
    }
    
    public struct Transition: Equatable {
        
        // Standard cross-fade transition
        public static let crossfade = Transition.fade()
        
        /// Standard navigation-style push
        public static let push = Transition.slide(from: .right)
        
        /// Standard navigation-style pop
        public static let pop = Transition.slide(from: .left)
        
        /// Standard modal-style present
        public static let present = Transition.cover(from: .bottom)
        
        /// Standard modal-style dismiss
        public static let dismiss = Transition.reveal(from: .top)
        
        /// Create a fade transition
        /// Fades in the new view controller
        public static func fade(duration: TimeInterval = Transition.standardDuration,
                                easing: TransitionEasing = .easeInOut,
                                backgroundColorOpacity: CGFloat? = Transition.standardBackgroundColorOpacity) -> Transition {
            return Transition(type: .fade, duration: duration, easing: easing)
        }
        
        /// Create a slide (a.k.a push) transition
        /// New controller slides in as the old one slides out in the same direction.
        public static func slide(from direction: TransitionDirection,
                                 duration: TimeInterval = Transition.standardDuration,
                                 easing: TransitionEasing = .easeInOut,
                                 backgroundColorOpacity: CGFloat? = Transition.standardBackgroundColorOpacity) -> Transition {
            return Transition(type: .slide, direction: direction, duration: duration, easing: easing)
        }
        
        /// Create a cover transition
        /// New view controller slides in on top of old view controller (which remains stationary).
        public static func cover(from direction: TransitionDirection,
                                 duration: TimeInterval = Transition.standardDuration,
                                 easing: TransitionEasing = .easeInOut,
                                 backgroundColorOpacity: CGFloat? = Transition.standardBackgroundColorOpacity) -> Transition {
            return Transition(type: .cover, direction: direction, duration: duration, easing: easing)
        }
        
        /// Create a reveal transition
        /// Old view controller slides out, revealing the new view controller (which remains stationary)
        public static func reveal(from direction: TransitionDirection,
                                  duration: TimeInterval = Transition.standardDuration,
                                  easing: TransitionEasing = .easeInOut,
                                  backgroundColorOpacity: CGFloat? = Transition.standardBackgroundColorOpacity) -> Transition {
            return Transition(type: .reveal, direction: direction, duration: duration, easing: easing)
        }
        
        /// Default duration of transitions
        public static let standardDuration: TimeInterval = 0.33
        
        /// Default minimum opacity used to animate the opacity of the "behind" view controller
        public static let standardBackgroundColorOpacity: CGFloat? = 1.0
        
        private let type: TransitionType
        private let direction: TransitionDirection?
        private let duration: TimeInterval
        private let easing: TransitionEasing
        fileprivate let backgroundColorOpacity: CGFloat?
        
        fileprivate init(type: TransitionType,
                         direction: TransitionDirection? = nil,
                         duration: TimeInterval = Transition.standardDuration,
                         easing: TransitionEasing = .easeInOut,
                         backgroundColorOpacity: CGFloat? = Transition.standardBackgroundColorOpacity) {
            self.type = type
            self.direction = direction
            self.easing = easing
            self.duration = duration
            self.backgroundColorOpacity = backgroundColorOpacity
        }
        
        fileprivate var animation: CATransition {
            return CATransition()
                .set(type: type.caType, subtype: direction?.caType)
                .set(duration: duration, function: easing.function)
        }
    }
    
    public enum TransitionType {
        
        /// Fade between view controller
        case fade
        
        /// New controller slides in as the old one slides out in the same direction
        case slide
        
        /// New view controller slides in on top of old view controller (which remains stationary)
        case cover
        
        /// Old view controller slides out, revealing the new view controller (which remains stationary)
        case reveal
    }
    
    public enum TransitionDirection {
        
        /// → from left to right
        case left
        
        /// ← from right to left
        case right
        
        /// ↓ from top to bottom
        case top
        
        /// ↑ from bottom to top
        case bottom
    }
    
    public enum TransitionEasing {
        
        /// Constant speed from beginning to end
        case linear
        
        /// Begins slowly, speeds up as it progresses
        case easeIn
        
        /// Begins quickly, slows as it progresses,
        case easeOut
        
        /// Begins slowly, accelerates through the middle, then slows again near completion
        case easeInOut
    }
    
}

extension UIWindow.TransitionType {
    fileprivate var caType: CATransitionType {
        switch self {
        case .fade: return .fade
        case .slide: return .push
        case .cover: return .moveIn
        case .reveal: return .reveal
        }
    }
}

extension UIWindow.TransitionDirection {
    fileprivate var caType: CATransitionSubtype {
        switch self {
        case .left: return .fromLeft
        case .right: return .fromRight
        case .top: return .fromBottom
        case .bottom: return .fromTop
        }
    }
}

extension UIWindow.TransitionEasing {
    fileprivate var function: CAMediaTimingFunction {
        switch self {
        case .linear: return CAMediaTimingFunction(name: .linear)
        case .easeIn: return CAMediaTimingFunction(name: .easeIn)
        case .easeOut: return CAMediaTimingFunction(name: .easeOut)
        case .easeInOut: return CAMediaTimingFunction(name: .easeInEaseOut)
        }
    }
}

extension CATransition {
    fileprivate func set(type: CATransitionType, subtype: CATransitionSubtype? = nil) -> CATransition {
        self.type = type
        self.subtype = subtype
        return self
    }
    
    fileprivate func set(duration: CFTimeInterval, function: CAMediaTimingFunction) -> CATransition {
        self.duration = duration
        self.timingFunction = function
        return self
    }
}
