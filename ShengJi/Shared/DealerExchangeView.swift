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
    
    private lazy var cardsRemainingLabel: UILabel = { // todo make into stack views of button images
        let label = UILabel()
        return label
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
        
        addSubview(cardsRemainingLabel)
        addSubview(doneButton)
        
        cardsRemainingLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(24)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cardsRemainingLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ cardsRemaining: [String]) {
        cardsRemainingLabel.text = cardsRemaining.joined()
    }
    
    @objc
    private func doneButtonTapped() {
        delegate?.dealerExchangeViewDidTapDoneButton()
    }
}
