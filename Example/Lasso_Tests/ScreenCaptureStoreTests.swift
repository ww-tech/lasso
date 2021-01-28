//
// ==----------------------------------------------------------------------== //
//
//  ScreenCaptureStoreTests.swift
//
//  Created by Steven Grosmark on 1/27/20.
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

class ScreenCaptureStoreTests: XCTestCase {

    func test_weakReference_usingScreen() {
        weak var weakStore: MyScreenModule.Store?
        
        // when - create screen and capture the type-erased store
        var screen: MyScreenModule.Screen? =
            MyScreenModule
                .createScreen()
                .captureStore(as: &weakStore)
        
        // then - should have non-nil refs
        XCTAssertNotNil(screen)
        XCTAssertNotNil(weakStore)
        
        // when - ref to screen is let go of
        screen = nil
        
        // then - underlying ref to type-erased store becomes nil
        XCTAssertNil(weakStore)
    }
    
    func test_weakReference_usingViewController() {
        weak var weakStore: MyScreenModule.Store?
        
        // when - create screen and capture the type-erased store
        var controller: UIViewController? =
            MyScreenModule
                .createScreen()
                .captureStore(as: &weakStore)
                .controller
        
        // then - should have non-nil refs
        XCTAssertNotNil(controller)
        XCTAssertNotNil(weakStore)
        
        // when - ref to view controller is let go of
        controller = nil
        
        // then - underlying ref to type-erased store becomes nil
        XCTAssertNil(weakStore)
    }
    
    func test_weakReference_usingFlow() throws {
        
        // given - a flow and a place to start it
        let flow = MyFlow()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        
        try autoreleasepool {
            
            // when - flow started in the nav
            flow.start(with: root(of: navigationController))
            
            // then
            XCTAssertNil(flow.store)
            
            // when - next screen in flow is pushed
            let controller = try unwrap(flow.initialController as? MyController)
            controller.store.dispatchAction(.something)
            
            // then - flow has captured a reference to the 2nd screen's store
            XCTAssertNotNil(flow.store)
            
            // when - ref to 2nd screen's view controller is let go of (via navigation pop)
            flow.unwind()
            
        }
        
        // then - weak reference to store in the flow has been released
        XCTAssertNil(flow.store)
    }

}

extension XCTestCase {
    
    fileprivate func unwrap<T>(_ optional: T?, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) throws -> T {
        guard let value = optional else {
            XCTFail(message ?? "\(T.self) value is nil", file: file, line: line)
            throw NilError.nilValueEncountered
        }
        return value
    }
    
    fileprivate enum NilError: Error {
        case nilValueEncountered
    }
    
}

private enum MyScreenModule: ScreenModule {
    static func createScreen(with store: MyStore) -> Screen {
        return Screen(store, MyController(store.asViewStore()))
    }
    enum Action: Equatable { case something }
    enum Output: Equatable { case something }
}

private final class MyStore: LassoStore<MyScreenModule> {
    override func handleAction(_ action: Action) {
        dispatchOutput(.something)
    }
}

private final class MyController: UIViewController {
    let store: MyScreenModule.ViewStore
    
    init(_ store: MyScreenModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { return nil }
}

private final class MyFlow: Flow<NoOutputNavigationFlow> {
    weak var store: MyScreenModule.Store?
    
    override func createInitialController() -> UIViewController {
        return MyScreenModule
            .createScreen()
            .observeOutput { [weak self] _ in self?.createNext() }
            .controller
    }
    
    private func createNext() {
        guard let nav = context else { return }
        MyScreenModule
            .createScreen()
            .captureStore(as: &store)
            .place(with: pushed(in: nav, animated: false))
    }
}
