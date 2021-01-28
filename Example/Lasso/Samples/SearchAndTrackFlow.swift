//
// ==----------------------------------------------------------------------== //
//
//  SearchAndTrackFlow.swift
//
//  Created by Trevor Beasty on 7/18/19.
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

struct Food: SearchListRepresentable, Equatable {
    let name: String
    let points: Int
    let description: String
    
    var searchListTitle: String {
        return "\(name), \(String(points)) points"
    }
    
    // service call
    static func getFoods(searchText: String?, completion: @escaping (Result<[Food], Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            if Bool.random() {
                let paulsToast = Food(name: "Paul's Toast", points: 2, description: "Extra toasted with light butter")
                completion(.success([paulsToast]))
            }
            else {
                completion(.failure(NSError()))
            }
        })
    }
    
}

class SearchAndTrackFlow: Flow<NoOutputFlow> {
    
    var searchScreenFactory = SearchScreenModule<Food>.ScreenFactory(configure: { searchStore in
        searchStore.getSearchResults = Food.getFoods
    })
    var foodDetailScreenFactory = TextScreenModule.ScreenFactory()
    
    override func createInitialController() -> UIViewController {
        return assembleSearch()
    }
    
    private func assembleSearch() -> UIViewController {
        return searchScreenFactory.createScreen()
            .observeOutput({ [weak self] output in
                guard let self = self else { return }
                switch output {
                    
                case .didSelectItem(let food):
                    let food = self.assembleFoodDetail(food)
                    self.nextPresentedInFlow?.place(food)
                }
            })
            .controller
    }
    
    private func assembleFoodDetail(_ food: Food) -> UIViewController {
        let description = "\(food.points) Points\n\n\(food.description)"
        let state = TextScreenModule.State(title: food.name, description: description, buttons: ["Track"])
        return foodDetailScreenFactory.createScreen(with: state)
            .observeOutput({ [weak self] output in
                switch output {
                
                case .didTapButton:
                    self?.unwind()
                }
            })
            .controller
    }
    
}
