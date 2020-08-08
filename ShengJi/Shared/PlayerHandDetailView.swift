//
//  PlayerHandDetailView.swift
//  ShengJi
//
//  Created by Ray Kim on 8/1/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol PlayerHandDetailViewDelegate: class {
    func playerHandDetailViewDidSelectCard(_ cardAbbreviation: String)
}

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
    
    var gameState: GameView.GameState = .draw {
        didSet {
            switch gameState {
            case .play(let username, let card, _):
                guard self.username == username, card != "" else {
                    return
                }
//                removeCard(card)
            default:
                break
            }
        }
    }
    var selectedCard: CardView?
    private var levelTrump: String?
    private var cards: [String] = []
    private let username: String
    private weak var delegate: PlayerHandDetailViewDelegate?
    
    init(username: String, delegate: PlayerHandDetailViewDelegate) {
        self.username = username
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(cardsStackView)
        cardsStackView.addArrangedSubview(firstRowStackView)
        cardsStackView.addArrangedSubview(secondRowStackView)
        
        cardsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Only call this function when adding an additional card. Do not use to remove any cards
    /// nor to add multiple at once.
    func addCard(_ cards: [String]) {
        guard cards.count == cardsCount + 1 else {
            return
        }
        
        self.cards = cards
        let cardView = CardView(cardAbbreviation: cards[cards.count - 1], delegate: self)
        
        if cardsCount < 6 {
            firstRowStackView.addArrangedSubview(cardView)
        } else {
            secondRowStackView.addArrangedSubview(cardView)
        }
        
        // We'll start sorting after adding once the level trump has been set.
        if let levelTrump = levelTrump {
            sortHand(levelTrump: levelTrump)
        }
    }
    
    func removeCard(_ cardAbbreviation: String) {
        guard !cards.isEmpty else {
            return
        }
        
        self.cards.removeAll(where: { $0 == cardAbbreviation })
        
        if let subview = firstRowStackView.arrangedSubviews.first(where: { ($0 as? CardView)?.cardAbbreviation == cardAbbreviation }) {
            firstRowStackView.removeArrangedSubview(subview)
            firstRowStackView.layoutIfNeeded()
        } else if let subview = secondRowStackView.arrangedSubviews.first(where: { ($0 as? CardView)?.cardAbbreviation == cardAbbreviation }) {
            secondRowStackView.removeArrangedSubview(subview)
            secondRowStackView.layoutIfNeeded()
        }
    }
    
    func exchange(card: String, with otherCard: String) {
        guard cards.count == 12, let selectedCard = selectedCard else {
            return
        }
        selectedCard.update(otherCard)
        selectedCard.deselect()
        self.selectedCard = nil
    }
    
    func sortHand(levelTrump: String) {
        guard levelTrump.count == 2 else {
            return
        }

        self.levelTrump = levelTrump

        cards.sortBy(levelTrump: levelTrump)
        
        // Both top and bottom rows should be in descending ranking from right to left. The leftmost
        // card on the top row should be the next highest value card from the rightmost card on the
        // bottom row.
        for (index, card) in cards.enumerated() {
            let firstRowSubviewsCount = firstRowStackView.arrangedSubviews.count
            let secondRowSubviewsCount = secondRowStackView.arrangedSubviews.count
            if index < 6, let cardView = firstRowStackView.arrangedSubviews[firstRowSubviewsCount - 1 - index] as? CardView {
                cardView.update(card)
            } else if let cardView = secondRowStackView.arrangedSubviews[secondRowSubviewsCount - 1 - (index - 6)] as? CardView {
                cardView.update(card)
            }
        }
    }
    
    func deselectCards() {
        selectedCard?.deselect()
    }
    
    func setIsEnabled(_ isEnabled: Bool) {
        for card in firstRowStackView.arrangedSubviews + secondRowStackView.arrangedSubviews {
            (card as? CardView)?.setIsEnabled(isEnabled)
        }
    }
}

extension PlayerHandDetailView: CardViewDelegate {
    func cardViewDidSelectCard(_ card: CardView) {
        guard gameState != .draw else {
            return
        }
        
        selectedCard?.deselect()
        selectedCard = card
        selectedCard?.select()
        delegate?.playerHandDetailViewDidSelectCard(card.cardAbbreviation)
    }
}
