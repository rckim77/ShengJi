//
//  PlayerHandView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/31/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

final class PlayerHandView: UIView {
    
    enum PlayerPosition {
        case bottom, left, top, right
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var turnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        label.isHidden = true
        return label
    }()
    
    private lazy var handLabel: UILabel = { // todo: make into a card view
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "0"
        return label
    }()
    
    private let position: PlayerPosition

    var username: String? {
        usernameLabel.text
    }
    
    // MARK: - Init methods
    
    init(position: PlayerPosition) {
        self.position = position
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        switch position {
        case .bottom, .left, .right:
            stackView.addArrangedSubview(usernameLabel)
            stackView.addArrangedSubview(turnLabel)
            stackView.addArrangedSubview(handLabel)
        case .top:
            stackView.addArrangedSubview(handLabel)
            stackView.addArrangedSubview(usernameLabel)
            stackView.addArrangedSubview(turnLabel)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        turnLabel.text = position == .bottom ? "Your turn" : "Their turn"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(username: String) {
        usernameLabel.text = username
    }
    
    func hideTurnLabel(_ shouldHide: Bool) {
        turnLabel.isHidden = shouldHide
    }
    
    func updateHandLabel(text: String) {
        handLabel.text = text
    }
}
