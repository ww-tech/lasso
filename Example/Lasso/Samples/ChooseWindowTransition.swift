//
//===----------------------------------------------------------------------===//
//
//  ChooseWindowTransition.swift
//
//  Created by Steven Grosmark on 6/6/19.
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

import UIKit
import Lasso

// MARK: - Flow

/// A flow that recursively restarts itself to demonstrate various
/// transition types for replacing a UIWindow's rootViewController.
/// When finished, the SampleCatalogFlow is re-started at the root
/// of the application window.
class ChooseWindowTransitionFlow: Flow<NoOutputFlow> {
    
    override func createInitialController() -> UIViewController {
        return ChooseWindowTransition
            .createScreen()
            .observeOutput { output in
                switch output {
                    
                case .didSelectTransition(let transition):
                    ChooseWindowTransitionFlow().start(with: rootOfApplicationWindow(using: transition))
                    
                case .didTapDone:
                    SampleCatalogFlow().start(with: rootOfApplicationWindow(using: .pop)?.withNavigationEmbedding())
                }
            }
            .controller
    }
    
}

// MARK: - Module

enum ChooseWindowTransition: ScreenModule {
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: ChooseWindowTransitionStore) -> Screen {
        let controller = ChooseWindowTransitionController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
    enum Action: Equatable {
        case didSelectTransition(UIWindow.Transition)
        case didTapDone
    }
    
    typealias Output = Action
    
    struct State: Equatable {
        let background: UIColor
        let items: [Item]
    }
    
    struct Item: Equatable {
        let name: String
        let transition: UIWindow.Transition
        init(_ name: String, _ transition: UIWindow.Transition) {
            self.name = name
            self.transition = transition
        }
    }
    
}

class ChooseWindowTransitionStore: LassoStore<ChooseWindowTransition> {
    
    override func handleAction(_ action: Action) {
        dispatchOutput(action)
    }
    
}

extension ChooseWindowTransition.State {
    typealias Item = ChooseWindowTransition.Item
    
    init() {
        background = UIColor(red: .random(in: 0.75...1.0), green: .random(in: 0.75...1.0), blue: .random(in: 0.75...1.0), alpha: 1.0)
        items = [
            Item("Fade\n(fade)", .crossfade),
            Item("Slide ←\n(push)", .slide(from: .right)),
            Item("Slide →\n(pop)", .slide(from: .left)),
            Item("Slide ↑", .slide(from: .bottom)),
            Item("Slide ↓", .slide(from: .top)),
            
            Item("Cover ←", .cover(from: .right)),
            Item("Cover →", .cover(from: .left)),
            Item("Cover ↑\n(present)", .cover(from: .bottom)),
            Item("Cover ↓", .cover(from: .top)),
            
            Item("Reveal ←", .reveal(from: .right)),
            Item("Reveal →", .reveal(from: .left)),
            Item("Reveal ↑", .reveal(from: .bottom)),
            Item("Reveal ↓\n(dismiss)", .reveal(from: .top))
        ]
    }
}

// MARK: - View controller

class ChooseWindowTransitionController: UIViewController, LassoView {
    
    let store: ChooseWindowTransition.ViewStore
    private var collectionView: UICollectionView!
    
    init(store: ChooseWindowTransition.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = store.state.background
        
        let button = UIButton(standardButtonWithTitle: "Done 👋")
        view.addSubview(button)
        button.layout.fill(.safeArea, axis: .x, inset: 30).bottom(to: .safeArea, offset: -30)
        
        button.bind(to: store, action: .didTapDone)
        
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        let w = floor(min(view.frame.width, view.frame.height) / 3) - 28
        flowLayout.itemSize = CGSize(width: w, height: w)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = store.state.background
        view.addSubview(collectionView)
        collectionView.layout
            .top(to: .safeArea, offset: 20)
            .fill(.safeArea, axis: .x, inset: 20)
            .bottom(to: button, edge: .top, offset: -30)
    }
    
}

extension ChooseWindowTransitionController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.state.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let item = store.state.items[indexPath.row]
        
        cell.contentView.subviews.reversed().forEach { $0.removeFromSuperview() }
        
        let borderView = UIView()
            .set(cornerRadius: 7)
            .set(borderColor: .black, thickness: 1)
        
        cell.contentView.addSubview(borderView)
        borderView.layout.fill(.superview, inset: 8)
        
        let label = UILabel()
        label.text = item.name
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        cell.contentView.addSubview(label)
        label.layout.fill(.superview, inset: 5)
        
        return cell
    }
}

extension ChooseWindowTransitionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = store.state.items[indexPath.row]
        store.dispatchAction(.didSelectTransition(item.transition))
    }
    
}
