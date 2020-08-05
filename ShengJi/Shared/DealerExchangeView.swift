//
//  DealerExchangeView.swift
//  ShengJi
//
//  Created by Ray Kim on 8/2/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol DealerExchangeViewDelegate: class {
    func dealerExchangeViewDidTapDoneButton()
    func dealerExchangeViewDidTapExchangeButton()
    func dealerExchangeViewDidSelectCard(_ cardAbbreviation: String)
}

final class DealerExchangeView: UIView {
    
    private lazy var firstRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var secondRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.addRoundedBorder(color: .systemBlue)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    private lazy var exchangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Exchange", for: .normal)
        button.addTarget(self, action: #selector(exchangeButtonTapped), for: .touchUpInside)
        button.addRoundedBorder(color: .systemBlue)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    private weak var delegate: DealerExchangeViewDelegate?
    private var selectedCardButton: UIButton?
    private var cards: [String]?
    var selectedCardAbbreviation: String? {
        guard let selectedCardIndex = selectedCardButton?.tag else {
            return nil
        }
        return cards?[selectedCardIndex]
    }
    
    init(delegate: DealerExchangeViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        
        backgroundColor = .secondarySystemGroupedBackground
        addRoundedCorners(radius: 8)
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 3
        
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(firstRowStackView)
        verticalStackView.addArrangedSubview(secondRowStackView)
        addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(doneButton)
        buttonsStackView.addArrangedSubview(exchangeButton)
        
        verticalStackView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(12)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(verticalStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ cardsRemaining: [String]) {
        guard cardsRemaining.count == 6 else {
            return
        }
        
        self.cards = cardsRemaining
        
        let firstRow = cardsRemaining[0..<3]
        for (index, card) in firstRow.enumerated() {
            let button = createCard(card)
            button.tag = index
            button.addTarget(self, action: #selector(cardSelected), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 102, height: 144))
            }
            firstRowStackView.addArrangedSubview(button)
        }
        
        let secondRow = cardsRemaining[3..<6]
        for (index, card) in secondRow.enumerated() {
            let button = createCard(card)
            button.tag = index + 3
            button.addTarget(self, action: #selector(cardSelected), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 102, height: 144))
            }
            secondRowStackView.addArrangedSubview(button)
        }
    }
    
    func exchange(card: String, with otherCard: String) {
        guard let selectedCardButton = selectedCardButton,
            let cardIndex = cards?.firstIndex(of: card) else {
            return
        }
        selectedCardButton.setImage(UIImage(named: otherCard), for: .normal)
        cards?[cardIndex] = card
        selectedCardButton.layer.borderWidth = 0
        self.selectedCardButton = nil
    }
    
    @objc
    private func doneButtonTapped() {
        delegate?.dealerExchangeViewDidTapDoneButton()
    }
    
    @objc
    private func exchangeButtonTapped() {
        delegate?.dealerExchangeViewDidTapExchangeButton()
    }
    
    @objc
    private func cardSelected(sender: UIButton) {
        guard let cards = cards else {
            return
        }
        
        if let selectedCard = selectedCardButton {
            selectedCard.layer.borderWidth = 0
        }
        
        self.selectedCardButton = sender
        sender.addRoundedBorder(radius: 8, width: 2, color: .systemBlue)
        let cardAbbreviation = cards[sender.tag]
        delegate?.dealerExchangeViewDidSelectCard(cardAbbreviation)
    }
    
    private func createCard(_ abbreviation: String) -> UIButton {
        let button = UIButton(type: .custom)
        let cardImage = UIImage(named: abbreviation)
        button.setImage(cardImage, for: .normal)
        return button
    }
}
