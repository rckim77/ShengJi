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
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.addRoundedBorder(color: .systemBlue)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    private weak var delegate: DealerExchangeViewDelegate?
    
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
        addSubview(doneButton)
        
        verticalStackView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(24)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(verticalStackView.snp.bottom).offset(16)
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
        
        let firstRow = cardsRemaining[0..<3]
        for card in firstRow {
            let button = createCard(card)
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 99, height: 140))
            }
            firstRowStackView.addArrangedSubview(button)
        }
        
        let secondRow = cardsRemaining[3..<6]
        for card in secondRow {
            let button = createCard(card)
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 99, height: 140))
            }
            secondRowStackView.addArrangedSubview(button)
        }
    }
    
    @objc
    private func doneButtonTapped() {
        delegate?.dealerExchangeViewDidTapDoneButton()
    }
    
    private func createCard(_ abbreviation: String) -> UIButton {
        let button = UIButton(type: .custom)
        let cardImage = UIImage(named: abbreviation)
        button.setImage(cardImage, for: .normal)
        return button
    }
}
