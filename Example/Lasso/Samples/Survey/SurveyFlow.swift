//
// ==----------------------------------------------------------------------== //
//
//  SurveyFlow.swift
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
// ==----------------------------------------------------------------------== //
//

import UIKit
import Lasso

enum SurveyFlowModule: NavigationFlowModule {
    
    enum Output: Equatable {
        case didFinish(responses: SurveyStoreModule.Responses, prize: Prize?)
    }
    
    struct Prize: Equatable {
        let name: String
        let description: String
        let dollarValue: Int
    }
    
}

class SurveyFlow: Flow<SurveyFlowModule> {
    
    var getPrize = { (_: SurveyStoreModule.Responses, completion: @escaping (SurveyFlowModule.Prize?) -> Void) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            var prize: SurveyFlowModule.Prize?
            if Bool.random() {
                prize = SurveyFlowModule.Prize(name: "Free Cruise",
                                               description: "All expenses paid! Dinner with Oprah!",
                                               dollarValue: 10000)
            }
            completion(prize)
        }
    }
    
    private let questions: [SurveyStoreModule.Question]
    
    private lazy var surveyStore: SurveyStoreModule.Store = {
        let initialState = SurveyStore.State(questions: questions)
        let store = SurveyStore(with: initialState)
        
        store.observeOutput({ [weak self] (output) in
            switch output {
            case .didPressSubmit(question: let question):
                self?.handleDidPressSubmit(for: question)
            }
        })
        
        return store.asAnyStore()
    }()
    
    init(questions: [SurveyStoreModule.Question]) {
        self.questions = questions
    }
    
    override func createInitialController() -> UIViewController {
        guard let firstQuestion = questions.first else { return UIViewController() }
        return createController(for: firstQuestion)
    }
    
    private func createController(for question: SurveyStoreModule.Question) -> UIViewController {
        
        let controller = SurveyStoreModule.createQuestionController(using: surveyStore, for: question)
        controller.title = progressString(for: question)
        return controller
    }
    
    private func assemblePrizeScreen(prize: SurveyFlowModule.Prize) -> TextScreenModule.Screen {
        
        let initialState = TextScreenModule.State(title: "You won a \(prize.name)!!", description: "\(prize.description)\n\nA $\(prize.dollarValue) value!!", buttons: ["OMG!!"])
        
        return TextScreenModule.createScreen(with: initialState)
            .observeOutput({ [weak self] output in
                switch output {
                case .didTapButton:
                    self?.finish(prize: prize)
                }
                
            })
    }
    
    private func handleDidPressSubmit(for question: SurveyStoreModule.Question) {
        guard let i = questions.firstIndex(where: { $0 == question }) else { return }
        if i < questions.count - 1 {
            let nextQuestion = questions[i + 1]
            createController(for: nextQuestion).place(with: nextPushedInFlow)
        }
        else {
            submitForPrize()
        }
    }
    
    private func submitForPrize() {
        getPrize(responses) { [weak self] prize in
            executeOnMainThread {
                guard let self = self else { return }
                if let prize = prize {
                    self.assemblePrizeScreen(prize: prize).controller.place(with: self.nextPushedInFlow)
                }
                else {
                    self.finish()
                }
            }
        }
    }
    
    private func finish(prize: SurveyFlowModule.Prize? = nil) {
        dispatchOutput(.didFinish(responses: responses, prize: prize))
    }
    
    private var responses: SurveyStoreModule.Responses {
        return surveyStore.state.responses
    }
    
    private func progressString(for question: SurveyStoreModule.Question) -> String? {
        guard let i = questions.firstIndex(where: { $0 == question }) else { return nil }
        return "\(i + 1) of \(questions.count)"
    }
    
}

extension SurveyFlow {
    
    static var favorites: SurveyFlow {
        let questions = [
            "What are your favorite foods?",
            "If you were a superhero, what superpowers would you have?",
            "What are your favorite kinds of dogs?"
        ]
        return SurveyFlow(questions: questions)
    }
    
}
