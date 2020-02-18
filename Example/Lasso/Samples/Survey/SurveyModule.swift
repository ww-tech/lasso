//
//===----------------------------------------------------------------------===//
//
//  SurveyModule.swift
//
//  Created by Trevor Beasty on 6/5/19.
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

import Foundation
import Lasso

enum SurveyStoreModule: StoreModule {
    
    struct State: Equatable {
        let questions: [Question]
        var proposed: [Question: String]
        var responses: Responses
    }
    
    typealias Question = String
    typealias Answer = String
    typealias Responses = [Question: [Answer]]
    
    enum Action: Equatable {
        case didPressSubmit(question: Question)
        case didPressAdd(question: Question)
        case didEditProposed(question: Question, proposed: String?)
    }
    
    enum Output: Equatable {
        case didPressSubmit(question: Question)
    }
    
    static func createQuestionController(using store: Store, for question: Question) -> UIViewController {
        
        let stateMap = { (state: State) -> MakeListViewModule.ViewState in
            return MakeListViewModule.ViewState(
                header: question,
                placeholder: "",
                proposed: state.proposed[question],
                submitted: state.responses[question] ?? []
            )
        }
        
        let actionMap = { (viewAction: MakeListViewModule.ViewAction) -> Action in
            switch viewAction {
                
            case .didEditProposed(let proposed):
                return .didEditProposed(question: question, proposed: proposed)
            
            case .didPressAdd:
                return .didPressAdd(question: question)
            
            case .didPressSubmit:
                return .didPressSubmit(question: question)
            }
        }
        
        let viewStore = store.asViewStore(stateMap: stateMap, actionMap: actionMap)
        return MakeListViewController(store: viewStore)
    }
    
}

extension SurveyStoreModule.State {
    
    init(questions: [SurveyStoreModule.Question]) {
        self.init(questions: questions, proposed: [:], responses: questions.asDictionary([]))
    }
    
}

class SurveyStore: LassoStore<SurveyStoreModule> {
    
    override func handleAction(_ action: Action) {
        switch action {
            
        case .didPressSubmit(question: let question):
            dispatchOutput(.didPressSubmit(question: question))
            
        case .didPressAdd(question: let question):
            update { state in
                if let proposed = state.proposed[question], !proposed.isEmpty {
                    state.responses[question]?.append(proposed)
                    state.proposed[question] = nil
                }
            }
            
        case let .didEditProposed(question: question, proposed: proposed):
            update { state in
                state.proposed[question] = proposed
            }
        }
    }
    
}

private extension Array where Element: Hashable {
    
    func asDictionary<Value>(_ value: Value) -> [Element: Value] {
        return reduce(into: [:], { (dict, element) in
            dict[element] = value
        })
    }
    
}
