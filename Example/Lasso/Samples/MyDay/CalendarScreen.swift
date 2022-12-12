//
// ==----------------------------------------------------------------------== //
//
//  CalendarScreen.swift
//
//  Created by Trevor Beasty on 10/21/19.
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

import Foundation
import UIKit
import Lasso
import WWLayout

enum CalendarScreenModule: ScreenModule {

    struct State: Equatable {
        var selectedDate = Date()
    }

    enum Action: Equatable {
        case didSelectDate(Date)
    }

    enum Output: Equatable { }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: CalendarStore) -> Screen {
        let controller = CalendarController(store: store.asViewStore())
        return Screen(store, controller)
    }

}

class CalendarStore: LassoStore<CalendarScreenModule> {

    override func handleAction(_ action: CalendarScreenModule.Action) {
        switch action {

        case .didSelectDate(let date):
            update { $0.selectedDate = date }
        }
    }

}

class CalendarController: UIViewController, LassoView {

    let store: CalendarScreenModule.ViewStore

    private let datePicker = UIDatePicker()

    init(store: CalendarScreenModule.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    private func setUpView() {
        view.addSubview(datePicker)
        datePicker.layout
            .fill(.superview)
        datePicker.datePickerMode = .date
    }

    private func bind() {
        store.observeState(\.selectedDate) { [weak self] (date) in
            self?.datePicker.setDate(date, animated: true)
        }

        datePicker.bindDateChange(to: store) { .didSelectDate($0) }
    }

}
