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
    
    private lazy var usernameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .firstBaseline
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var dealerImageView: UIImageView = {
        let image = UIImage(systemName: "star.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var turnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        label.isHidden = true
        return label
    }()
    
    private lazy var handStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
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
        imageView.contentMode = .scaleAspectFit
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
        stackView.addArrangedSubview(turnLabel)
        stackView.addArrangedSubview(usernameStackView)
        usernameStackView.addArrangedSubview(usernameLabel)
        usernameStackView.addArrangedSubview(dealerImageView)
        
        switch position {
        case .bottom:
            stackView.addArrangedSubview(bottomHandDetailView)
            
            usernameStackView.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            
            stackView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(8)
                make.leading.trailing.equalToSuperview().inset(2)
            }
        case .left, .right, .top:
            stackView.addArrangedSubview(handStackView)
            handStackView.addArrangedSubview(handLabel)
            handStackView.addArrangedSubview(handImageView)
            
            usernameStackView.layoutMargins = .zero
            
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(12)
            }
        }

        turnLabel.text = position == .bottom ? "Your turn" : "Their turn"
        dealerImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(username: String) {
        usernameLabel.text = username
    }
    
    func hideTurnLabel(_ shouldHide: Bool) {
        // only update isHidden if it's different from current value due to a stack view bug
        // where the same calls to isHidden accumulate
        guard shouldHide != turnLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: 0.2) {
            self.turnLabel.isHidden = shouldHide
            self.turnLabel.alpha = shouldHide ? 0 : 1
        }
    }
    
    func updateHandUI(hand: [String]) {
        if position == .bottom {
            bottomHandDetailView.addCard(hand)
        } else {
            handLabel.text = "\(hand.count)"
        }
    }
    
    func updateAsDealer() {
        updateAsLeader()
        dealerImageView.isHidden = false
    }
    
    func updateAsLeader() {
        layer.borderWidth = 3
        layer.borderColor = UIColor.systemBlue.cgColor
    }
}
