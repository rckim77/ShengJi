//
//  CardView.swift
//  ShengJi
//
//  Created by Ray Kim on 8/1/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol CardViewDelegate: class {
    func cardViewDidSelectCard(_ card: CardView)
}

final class CardView: UIView {
    
    private lazy var cardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(cardImage, for: .normal)
        button.addTarget(self, action: #selector(cardButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var cardImage: UIImage? {
        UIImage(named: cardAbbreviation)
    }
    
    var cardAbbreviation: String
    private weak var delegate: CardViewDelegate?
    
    /// Input can be, for example, "2C" for the 2 of clubs.
    init(cardAbbreviation: String, delegate: CardViewDelegate) {
        self.cardAbbreviation = cardAbbreviation
        self.delegate = delegate
        super.init(frame: .zero)

        backgroundColor = .systemGroupedBackground
        addSubview(cardButton)
        
        cardButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(CGSize(width: 99, height: 140))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select() {
        cardButton.addRoundedBorder(radius: 8, width: 2, color: .systemBlue)
    }
    
    func deselect() {
        cardButton.layer.borderWidth = 0
    }
    
    func setIsEnabled(_ isEnabled: Bool) {
        cardButton.isEnabled = isEnabled
    }
    
    func update(_ cardAbbreviation: String) {
        self.cardAbbreviation = cardAbbreviation
        cardButton.setImage(cardImage, for: .normal)
    }
    
    @objc
    private func cardButtonTapped() {
        delegate?.cardViewDidSelectCard(self)
    }
}
