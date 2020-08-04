//
//  CardView.swift
//  ShengJi
//
//  Created by Ray Kim on 8/1/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

final class CardView: UIView {
    
    private lazy var cardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(cardImage, for: .normal)
        // add target
        return button
    }()
    
    private var cardImage: UIImage? {
        UIImage(named: cardAbbreviation)
    }
    
    private let cardAbbreviation: String
    
    /// Input can be, for example, "2C" for the 2 of clubs.
    init(cardAbbreviation: String) {
        self.cardAbbreviation = cardAbbreviation
        super.init(frame: .zero)

        backgroundColor = .systemGroupedBackground
        addSubview(cardButton)
        
        cardButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(140)
            make.width.equalTo(99)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
