//
// ==----------------------------------------------------------------------== //
//
//  DailyLogScreen.swift
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

// MARK: - Module

enum DailyLogScreenModule: ScreenModule {

    struct State: Equatable {
        var display: Display
        var isLoading: Bool

        enum Display: Equatable {
            case main(log: DailyLog)
            case error
            case empty
        }
    }

    enum Action: Equatable {
        case updateForDate(Date)
    }
    
    static var defaultInitialState: DailyLogScreenModule.State {
        return State(display: .empty, isLoading: false)
    }
    
    static func createScreen(with store: DailyLogStore) -> Screen {
        let viewStore: DailyLogViewModule.ViewStore = store.asViewStore(stateMap: { $0.toViewState() })
        let controller = DailyLogController(store: viewStore)
        return Screen(store, controller)
    }

}

extension DailyLogScreenModule.State {
    
    func toViewState() -> DailyLogViewModule.ViewState {
        let text: String
        switch display {
            
        case .empty:
            text = ""
            
        case .error:
            text = "Error"
            
        case .main(log: let log):
            text = """
            program: \(log.program)
            calories consumed: \(log.caloriesConsumed)
            calories remaining: \(log.caloriesRemaining)
            steps taken: \(log.stepsTaken)
            """
        }
        return DailyLogViewModule.ViewState(text: text, isLoading: isLoading)
    }
        
}

// MARK: - Store

class DailyLogStore: LassoStore<DailyLogScreenModule> {
    
    var getDailyLog = DailyLogService.getDailyLog
    var user = User.current

    override func handleAction(_ action: DailyLogScreenModule.Action) {
        switch action {

        case .updateForDate(let date):
            update { $0.isLoading = true }
            getDailyLog(date, user.id) { [weak self] result in
                self?.batchUpdate { $0.isLoading = false }
                switch result {

                case .success(let log):
                    self?.update { $0.display = .main(log: log) }

                case .failure:
                    self?.update { $0.display = .error }
                }
            }
        }
    }

}

// MARK: - View

enum DailyLogViewModule: ViewModule {
    
    struct ViewState: Equatable {
        var text: String
        var isLoading: Bool
    }
    
    typealias ViewAction = DailyLogScreenModule.Action
    
}

class DailyLogController: UIViewController, LassoView {

    let store: DailyLogViewModule.ViewStore

    private let label = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private let titleLabel = UILabel()

    init(store: DailyLogViewModule.ViewStore) {
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
        view.addSubview(titleLabel)
        titleLabel.layout
            .centerX(to: .superview)
            .top(to: .superview)
            .height(50)
        [label, activityIndicator].forEach {
            view.addSubview($0)
            $0.layout
                .left(to: .superview)
                .right(to: .superview)
                .top(to: titleLabel, edge: .bottom)
                .bottom(to: .superview, offset: -8)
                .height(120)
        }

        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        activityIndicator.hidesWhenStopped = true
        view.backgroundColor = .blue
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        titleLabel.textAlignment = .center
        titleLabel.text = "Daily Log"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
    }

    private func bind() {
        store.observeState(\.text) { [weak self] (text) in
            self?.label.text = text
        }

        store.observeState(\.isLoading) { [weak self] (isLoading) in
            if isLoading {
                self?.activityIndicator.startAnimating()
                self?.label.alpha = 0.3
            }
            else {
                self?.activityIndicator.stopAnimating()
                self?.label.alpha = 1.0
            }
        }
    }

}

// MARK: - User & service

class User {
    
    static let current = User(id: "abc123", program: .B)
    
    let id: String
    var program: Program
    
    init(id: String, program: Program) {
        self.id = id
        self.program = program
    }
    
}

enum Program: String, CaseIterable {
    case A
    case B
    case C
    
    static func random() -> Program {
        return allCases.randomElement() ?? .A
    }
}

struct DailyLog: Equatable {
    let program: Program
    let caloriesConsumed: Int
    let caloriesRemaining: Int
    let stepsTaken: Int
}

enum DailyLogService {
        
    static func getDailyLog(date: Date, userId: String, completion: @escaping (Result<DailyLog, Error>) -> Void) {
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        let day = components.day ?? 0
        let month = components.month ?? 0
        let caloriesConsumed = 20 * day
        let log = DailyLog(program: .random(),
                           caloriesConsumed: caloriesConsumed,
                           caloriesRemaining: 2500 - caloriesConsumed,
                           stepsTaken: month * 500 + day * 10)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
            completion(.success(log))
        }
    }
    
}
