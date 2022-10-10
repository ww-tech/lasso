//
// ==----------------------------------------------------------------------== //
//
//  MyDayCardsScreen.swift
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

import Lasso
import WWLayout

enum MyDayCardsScreenModule: ScreenModule {
    
    struct State: Equatable {
        var cards: [String] = []
        var phase: Phase = .idle
        
        enum Phase {
            case idle
            case busy
            case error
        }
        
    }
    
    enum Action: Equatable {
        case updateForDate(date: Date)
        case didSelectCard(idx: Int)
    }
    
    enum Output: Equatable {
        case didSelectCard(card: String)
    }
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: MyDayCardsStore) -> Screen {
        let controller = MyDayCardsController(store: store.asViewStore())
        return Screen(store, controller)
    }
    
}

class MyDayCardsStore: LassoStore<MyDayCardsScreenModule> {
    
    var getCards = { (_: Date, completion: @escaping (Result<[String], Error>) -> Void) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let allCards = ["Yay apples", "Yay grapes", "Whoa exercise", "Get fit!!", "Healthy desserts", "Yay tomatoes"]
            var cards = [String]()
            for card in allCards where Bool.random() {
                cards.append(card)
            }
            completion(.success(cards.shuffled()))
        }
    }
    
    override func handleAction(_ action: MyDayCardsScreenModule.Action) {
        switch action {
            
        case .didSelectCard(idx: let idx):
            let card = state.cards[idx]
            dispatchOutput(.didSelectCard(card: card))
            
        case .updateForDate(date: let date):
            update { $0.phase = .busy }
            getCards(date) { [weak self] result in
                guard let self = self else { return }
                switch result {
                    
                case .success(let cards):
                    self.update {
                        $0.cards = cards
                        $0.phase = .idle
                    }
                    
                case .failure:
                    self.update {
                        $0.phase = .error
                    }
                }
            }
        }
    }
    
}

class MyDayCardsController: UIViewController, LassoView {
    
    let store: MyDayCardsScreenModule.ViewStore
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    private let collectionLayout = UICollectionViewFlowLayout()
    private let activityIndicator = UIActivityIndicatorView(style: .mediumGray)
    private let errorLabel = UILabel()
    private let titleLabel = UILabel()
    
    init(store: MyDayCardsScreenModule.ViewStore) {
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
            .left(to: .superview)
            .right(to: .superview)
            .top(to: .superview)
            .height(50)
        [collectionView, activityIndicator, errorLabel].forEach {
            view.addSubview($0)
            $0.layout
                .left(to: .superview)
                .right(to: .superview)
                .top(to: titleLabel, edge: .bottom, offset: 8)
                .bottom(to: .superview, offset: -8)
                .height(100)
        }
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionLayout.scrollDirection = .horizontal
        collectionView.backgroundColor = .white
        activityIndicator.hidesWhenStopped = true
        errorLabel.textAlignment = .center
        errorLabel.text = "Something went wrong"
        errorLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.text = "Articles"
        titleLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    private func bind() {
        store.observeState(\.cards) { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        store.observeState(\.phase) { [weak self] (phase) in
            if phase == .busy { self?.activityIndicator.startAnimating() }
            else { self?.activityIndicator.stopAnimating() }
            self?.collectionView.isHidden = phase == .error
            self?.collectionView.alpha = phase == .busy ? 0.4 : 1.0
            self?.errorLabel.isHidden = !(phase == .error)
        }
    }
    
}

extension MyDayCardsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.state.cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else { fatalError() }
        let card = store.state.cards[indexPath.row]
        cell.label.text = card
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 8.0
        return CGSize(width: 120, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        store.dispatchAction(.didSelectCard(idx: indexPath.row))
    }
    
}

class CardCell: UICollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.layout.fill(.superview)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .orange
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
