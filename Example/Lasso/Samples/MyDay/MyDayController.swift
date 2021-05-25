//
// ==----------------------------------------------------------------------== //
//
//  MyDayController.swift
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

import UIKit
import Lasso
import WWLayout

class MyDayController: UIViewController {
    
    var calendarScreenFactory = CalendarScreenModule.ScreenFactory()
    var dailyLogScreenFactory = DailyLogScreenModule.ScreenFactory()
    var cardsScreenFactory = MyDayCardsScreenModule.ScreenFactory()

    private lazy var calendarScreen = calendarScreenFactory.createScreen(with: CalendarScreenModule.State(selectedDate: initialDate))
    private(set) lazy var cardsScreen = cardsScreenFactory.createScreen()
    private lazy var dailyLogScreen = dailyLogScreenFactory.createScreen()
    
    private let initialDate: Date
    
    init(date: Date = Date()) {
        self.initialDate = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private let myDayLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    private func setUpView() {
        [calendarScreen.controller, dailyLogScreen.controller, cardsScreen.controller].forEach {
            addChild($0)
            view.addSubview($0.view)
        }
        view.addSubview(myDayLabel)
        myDayLabel.layout
            .centerX(to: .superview)
            .top(to: .safeArea)
            .height(100)
        calendarScreen.controller.view.layout
            .left(to: .superview)
            .right(to: .superview)
            .top(to: myDayLabel, edge: .bottom)
            .height(120)
        cardsScreen.controller.view.layout
            .left(to: .superview)
            .right(to: .superview)
            .top(to: calendarScreen.controller.view, edge: .bottom, offset: 8)
        dailyLogScreen.controller.view.layout
            .left(to: .superview, offset: 8)
            .right(to: .superview, offset: -8)
            .top(to: cardsScreen.controller.view, edge: .bottom, offset: 24)
        [calendarScreen.controller, dailyLogScreen.controller, cardsScreen.controller].forEach {
            $0.didMove(toParent: self)
        }
        myDayLabel.font = UIFont.boldSystemFont(ofSize: 24)
        myDayLabel.textAlignment = .center
        myDayLabel.textColor = .purple
        myDayLabel.text = "My Day"
        view.backgroundColor = .background
    }

    private func bind() {
        calendarScreen.store.observeState(\.selectedDate) { [weak self] (date) in
            self?.dailyLogScreen.store.dispatchAction(.updateForDate(date))
            self?.cardsScreen.store.dispatchAction(.updateForDate(date: date))
        }
    }
}
