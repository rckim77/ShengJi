//
//  PlayerHandDetailVIew.swift
//  ShengJi
//
//  Created by Ray Kim on 8/1/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

/// Used as the hand view from the user's perspective (i.e., the bottom player) which displays the full card values.
final class PlayerHandDetailView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -68
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCards(_ cards: [String]) {
        guard cards.count != stackView.arrangedSubviews.count else {
            return
        }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for card in cards {
            let cardView = CardView(text: card)
            stackView.addArrangedSubview(cardView)
        }
    }
}
