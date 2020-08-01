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
    
    private lazy var handLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "0"
        return label
    }()
    
    private lazy var handImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "square.stack.3d.up.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .label
        return imageView
    }()
    
    private lazy var bottomHandDetailView: PlayerHandDetailView = {
        let view = PlayerHandDetailView()
        return view
    }()
    
    private let position: PlayerPosition

    var username: String? {
        guard let name = usernameLabel.text else {
            return nil
        }
        // remove " (me)" part for bottom text
        return position == .bottom ? name.components(separatedBy: " ").first : name
    }
    
    // MARK: - Init methods
    
    init(position: PlayerPosition) {
        self.position = position
        super.init(frame: .zero)
        
        backgroundColor = .systemGroupedBackground
        addRoundedCorners(radius: 8)
        addSubview(stackView)
        
        switch position {
        case .bottom:
            stackView.addArrangedSubview(usernameLabel)
            stackView.addArrangedSubview(turnLabel)
            stackView.addArrangedSubview(handLabel)
            stackView.addArrangedSubview(bottomHandDetailView)
            
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(8)
            }
        case .left, .right, .top:
            stackView.addArrangedSubview(usernameLabel)
            stackView.addArrangedSubview(turnLabel)
            stackView.addArrangedSubview(handLabel)
            stackView.addArrangedSubview(handImageView)
            
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(12)
            }
        }

        turnLabel.text = position == .bottom ? "Your turn" : "Their turn"
        handImageView.isHidden = true
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
    
    func updateHandUI(hand: [String]) {
        handLabel.text = "\(hand.count)"
        handImageView.isHidden = hand.count == 0
        if position == .bottom {
            bottomHandDetailView.updateCards(hand)
        }
    }
}
