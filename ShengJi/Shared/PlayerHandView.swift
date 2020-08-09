//
//  PlayerHandView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/31/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol PlayerHandViewDelegate: class {
    func playerHandViewDidSelectCard(_ cardAbbreviation: String, position: PlayerHandView.PlayerPosition, hand: [String])
}

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
        let view = PlayerHandDetailView(delegate: self)
        return view
    }()
    
    private lazy var playCardImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var playedCard: String?
    
    private weak var delegate: PlayerHandViewDelegate?
    private let position: PlayerPosition

    var gameState: GameView.GameState = .draw {
        didSet {
            // Note: bottomHandDetailView does not maintain its own state.
            switch gameState {
            case .play(let username, let card, let nextUsername):
                // sync turn label, show play card for username, enable detail view only for nextUsername
                playCardImageView.isHidden = false
                hideTurnLabel(nextUsername != self.username)
                
                if position == .bottom {
                    bottomHandDetailView.setIsEnabled(self.username == nextUsername)
                    bottomHandDetailView.removeCard(card)
                }
                
                if self.username == username && card != "" {
                    playedCard = card
                    playCardImageView.image = UIImage(named: card)
                }

                handStackView.isHidden = position != .bottom
            case .turnEnd(let username, let card):
                hideTurnLabel(true)
                
                if position == .bottom {
                    bottomHandDetailView.setIsEnabled(false)
                    bottomHandDetailView.removeCard(card)
                }
                
                if self.username == username {
                    playCardImageView.image = UIImage(named: card)
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Helper vars

    var username: String? {
        guard let name = usernameLabel.text else {
            return nil
        }
        // remove " (me)" part for bottom text
        return position == .bottom ? name.components(separatedBy: " ").first : name
    }
    
    /// Used only for the bottom player view. Returns the selected card abbreviation if any.
    var selectedCard: String? {
        bottomHandDetailView.selectedCard?.cardAbbreviation
    }
    
    // MARK: - Init methods
    
    init(position: PlayerPosition, delegate: PlayerHandViewDelegate) {
        self.delegate = delegate
        self.position = position
        super.init(frame: .zero)
        
        backgroundColor = .systemGroupedBackground
        addRoundedCorners(radius: 8)
        addSubview(stackView)
        stackView.addArrangedSubview(turnLabel)
        stackView.addArrangedSubview(usernameStackView)
        usernameStackView.addArrangedSubview(usernameLabel)
        usernameStackView.addArrangedSubview(dealerImageView)
        stackView.addArrangedSubview(playCardImageView)
        
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
                make.top.bottom.equalToSuperview().inset(UIDevice.current.isSmallDevice ? 8 : 12)
                make.leading.trailing.equalToSuperview().inset(8)
            }
        }
        
        playCardImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIDevice.current.isSmallDevice ? 75 : 81, height: UIDevice.current.isSmallDevice ? 105 : 114))
        }

        turnLabel.text = position == .bottom ? "Your turn" : "Their turn"
        dealerImageView.isHidden = true
        playCardImageView.isHidden = true
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
    
    // MARK: - Bottom position methods

    func exchange(card: String, with otherCard: String) {
        guard position == .bottom else {
            return
        }
        bottomHandDetailView.exchange(card: card, with: otherCard)
    }
    
    func sortHand(levelTrump: String) {
        guard position == .bottom else {
            return
        }
        bottomHandDetailView.sortHand(levelTrump: levelTrump)
    }
    
    func deselectCards() {
        guard position == .bottom else {
            return
        }
        bottomHandDetailView.deselectCards()
    }
    
    // MARK: - Dealer/Exchange methods
    
    func updateAsDealer() {
        updateAsLeader()
        dealerImageView.isHidden = false
    }
    
    func updateAsLeader() {
        layer.borderWidth = 3
        layer.borderColor = UIColor.systemBlue.cgColor
    }
}

extension PlayerHandView: PlayerHandDetailViewDelegate {
    func playerHandDetailViewDidSelectCard(_ cardAbbreviation: String, withHand hand: [String]) {
        delegate?.playerHandViewDidSelectCard(cardAbbreviation, position: position, hand: hand)
    }
}
