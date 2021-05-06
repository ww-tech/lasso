//
// ==----------------------------------------------------------------------== //
//
//  ActionDispatchableBindingTests.swift
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

import XCTest
import Lasso

class ActionDispatchableBindingTests: XCTestCase {

    func test_BindButton_ToAction() {
        // given
        let store = TestModule.createScreen().store
        let button = UIButton()
        button.bind(to: store, action: .buttonTapped)
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        button.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(store.state.actions, [TestModule.Action.buttonTapped], "Expecting exactly one button tapped actions")
        
        // when
        button.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(store.state.actions, [TestModule.Action.buttonTapped, .buttonTapped], "Expecting exactly two button tapped actions")
    }
    
    func test_BindButton_ToClosure() {
        // given
        let store = TestModule.createScreen().store
        let button = UIButton()
        button.bind(to: store) { btn in
            XCTAssertEqual(button, btn)
            return .buttonTapped
        }
        button.bind(to: store) { _ in .gestureTapped }
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        button.sendActions(for: .touchUpInside)
        
        // then
        var expectation = [TestModule.Action.buttonTapped, .gestureTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly two actions")
        
        // when
        button.sendActions(for: .touchUpInside)
        
        // then
        expectation = [TestModule.Action.buttonTapped, .gestureTapped, .buttonTapped, .gestureTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly four actions")
    }
    
    func test_BindButton_ToMultipleActions() {
        // given
        let store = TestModule.createScreen().store
        let button = UIButton()
        button.bind(to: store, action: .buttonTapped)
        button.bind(to: store, action: .gestureTapped)
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        button.sendActions(for: .touchUpInside)
        
        // then
        let expectation = [TestModule.Action.buttonTapped, .gestureTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly two actions")
    }
    
    func test_BindButton_ToActionAndClosure() {
        // given
        let store = TestModule.createScreen().store
        let button = UIButton()
        button.bind(to: store, action: .buttonTapped)
        button.bind(to: store) { _ in .gestureTapped }
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        button.sendActions(for: .touchUpInside)
        
        // then
        let expectation = [TestModule.Action.buttonTapped, .gestureTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly two actions")
    }
    
    func test_BindTapGesture_ToAction() {
        // given
        let store = TestModule.createScreen().store
        let tap = UITapGestureRecognizer()
        tap.bind(to: store, action: .gestureTapped)
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        tap.sendActions()
        
        // then
        XCTAssertEqual(store.state.actions, [TestModule.Action.gestureTapped], "Expecting exactly one gesture tapped actions")
        
        // when
        tap.sendActions()
        
        // then
        XCTAssertEqual(store.state.actions, [TestModule.Action.gestureTapped, .gestureTapped], "Expecting exactly two gesture tapped actions")
    }
    
    func test_BindTapGesture_ToClosure() {
        // given
        let store = TestModule.createScreen().store
        let tap = UITapGestureRecognizer()
        tap.bind(to: store) { gesture in
            XCTAssertEqual(tap, gesture)
            return .gestureTapped
        }
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        tap.sendActions()
        
        // then
        var expectation = [TestModule.Action.gestureTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly one actions")
        
        // when
        tap.sendActions()
        
        // then
        expectation = [TestModule.Action.gestureTapped, .gestureTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly two actions")
    }
    
    func test_BindTapGesture_ToActionAndClosure() {
        // given
        let store = TestModule.createScreen().store
        let tap = UITapGestureRecognizer()
        tap.bind(to: store, action: .gestureTapped)
        tap.bind(to: store) { _ in .buttonTapped }
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        tap.sendActions()
        
        // then
        var expectation = [TestModule.Action.gestureTapped, .buttonTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly two actions")
        
        // when
        tap.sendActions()
        
        // then
        expectation = [TestModule.Action.gestureTapped, .buttonTapped, .gestureTapped, .buttonTapped]
        XCTAssertEqual(store.state.actions, expectation, "Expecting exactly four actions")
    }
    
    func test_BindTextChange_ToAction() {
        let store = TestModule.createScreen().store
        let textField = UITextField()
        textField.bindTextDidChange(to: store) { .textChanged($0) }
        XCTAssertTrue(store.state.actions.isEmpty, "no actions should have been dispatched at the start")
        
        // when
        textField.text = "hello"
        
        // then
        XCTAssertTrue(store.state.actions.isEmpty, "manually assigning text shouldn't trigger the action")
        
        // when
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
        
        // then
        XCTAssertEqual(store.state.actions, [TestModule.Action.textChanged("hello")], "Expecting to see \"hello\"")
        
        // when
        textField.text = "hello, mother"
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
        
        // then
        XCTAssertEqual(store.state.actions, [TestModule.Action.textChanged("hello"), .textChanged("hello, mother")], "Expecting to see text text change actions")
    }

}

private enum TestModule: ScreenModule {
    
    enum Action: Equatable {
        case buttonTapped
        case gestureTapped
        case textChanged(String)
    }
    
    struct State: Equatable {
        var actions = [Action]()
    }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: TestStore) -> Screen {
        let controller = UIViewController()
        return Screen(store, controller)
    }
    
}

private class TestStore: LassoStore<TestModule> {
    
    required init(with initialState: State? = nil) {
        super.init(with: initialState ?? State())
    }
    
    override func handleAction(_ action: Action) {
        update { state in
            state.actions.append(action)
        }
    }
}
