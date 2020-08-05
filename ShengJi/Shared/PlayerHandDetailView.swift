//
//  PlayerHandDetailView.swift
//  ShengJi
//
//  Created by Ray Kim on 8/1/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

/// Used as the hand view from the user's perspective (i.e., the bottom player) which displays the full card values.
final class PlayerHandDetailView: UIView {
    
    private lazy var firstRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -48
        return stackView
    }()
    
    private lazy var secondRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -48
        return stackView
    }()
    
    private lazy var cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = -52
        stackView.alignment = .center
        return stackView
    }()
    
    var cardsCount: Int {
        firstRowStackView.arrangedSubviews.count + secondRowStackView.arrangedSubviews.count
    }
    
    var selectedCard: CardView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cardsStackView)
        cardsStackView.addArrangedSubview(firstRowStackView)
        
        cardsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Only call this function when adding an additional card image. Do not use to remove any cards
    /// nor to add multiple at once.
    func addCard(_ cards: [String]) {
        guard cards.count == cardsCount + 1 else {
            return
        }
        
        let cardView = CardView(cardAbbreviation: cards[cards.count - 1], delegate: self)
        if cardsCount < 6 {
            firstRowStackView.addArrangedSubview(cardView)
        } else if cardsCount == 6 {
            cardsStackView.addArrangedSubview(secondRowStackView)
            secondRowStackView.addArrangedSubview(cardView)
        } else {
            secondRowStackView.addArrangedSubview(cardView)
        }
    }
}

extension PlayerHandDetailView: CardViewDelegate {
    func cardViewDidSelectCard(_ card: CardView) {
        guard cardsCount == 12 else {
            return
        }
        if let selectedCard = selectedCard {
            selectedCard.unselect()
        }
        self.selectedCard = card
        selectedCard?.select()
    }
}
