//
// ==----------------------------------------------------------------------== //
//
//  UIKitBindings.swift
//
//  Created by Steven Grosmark on 6/7/19.
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
import WWLayout
import Lasso

// MARK: - Module

enum UIKitBindingsScreenModule: ScreenModule {
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: UIKitBindingsStore) -> Screen {
        let controller = UIKitBindingsViewController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
    enum Action: Equatable {
        case didToggleOverdrive(Bool)
        case didChangeVolume(Float)
        case didSelectMode(Int)
        case didSelectPage(Int)
        case didChangeAmount(Double)
        case didEditText(String)
        case didChangeDate(Date)
        case didTapBarButton
        case didTapButton
    }
    
    struct State: Equatable {
        var lastAction: String = ""
    }
}

// MARK: - Store

class UIKitBindingsStore: LassoStore<UIKitBindingsScreenModule> {
    
    override func handleAction(_ action: Action) {
        update { state in
            state.lastAction = "\(action)"
        }
    }
    
}

// MARK: - View

class UIKitBindingsViewController: UIViewController, LassoView {
    
    let store: UIKitBindingsScreenModule.ViewStore
    
    init(store: UIKitBindingsScreenModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .action)
        navigationItem.rightBarButtonItem = barButton
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.layout.fill(.safeArea, except: .bottom, inset: 20)
        
        let onOffSwitch = UISwitch()
        
        let slider = UISlider()
        slider.isContinuous = true
        slider.layout.width(280)
        
        let segmentedControl = UISegmentedControl(items: ["Dark", "Light", "Auto"])
        segmentedControl.layout.width(280)
        
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 8
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .green
        pageControl.layout.width(280)
        
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 99
        stepper.isContinuous = true
        
        let textField = UITextField(placeholder: "Enter something")
        textField.layout.width(280)
        
        let button = UIButton(standardButtonWithTitle: "Button")
        button.layout.width(280)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.layout.size(280, 80)
        
        stack.addArrangedSubviews(onOffSwitch, slider, segmentedControl, pageControl, stepper, textField, button, datePicker, label)
        
        // bind value changed events to dispatch an action on the store:
        onOffSwitch.bindValueChange(to: store) { .didToggleOverdrive($0) }
        slider.bindValueChange(to: store) { .didChangeVolume($0) }
        segmentedControl.bindValueChange(to: store) { .didSelectMode($0) }
        pageControl.bindValueChange(to: store) { .didSelectPage($0) }
        stepper.bindValueChange(to: store) { .didChangeAmount($0) }
        textField.bindTextDidChange(to: store) { .didEditText($0) }
        datePicker.bindDateChange(to: store) { .didChangeDate($0) }
        
        // bind .touchUpInside directly to a dispatched action on the store:
        button.bind(to: store, action: .didTapButton)
        barButton.bind(to: store, action: .didTapBarButton)
        
        store.observeState(\.lastAction) { [weak label] lastAction in
            label?.text = lastAction
        }
    }
    
}

extension UIStackView {
    
    public func addArrangedSubviews(_ subviews: UIView...) {
        subviews.forEach(addArrangedSubview)
    }
}
