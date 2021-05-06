//
// ==----------------------------------------------------------------------== //
//
//  SignupIntroStoreTests.swift
//
//  Created by Steven Grosmark on 10/5/19.
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
import LassoTestUtilities
@testable import Lasso_Example

class SignupIntroStoreTests: XCTestCase, LassoStoreTestCase {

    let testableStore = TestableStore<SignupIntro.IntroStore>()

    override func setUp() {
        super.setUp()
        store = Store(with: EmptyState())
    }

    func test_TheOneAndOnlyButton() {
        store.dispatchAction(.didTapNext)
        XCTAssertOutputs([.didTapNext])
    }

}
