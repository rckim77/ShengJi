//
//  GameStartView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/24/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine

protocol GameStartViewDelegate: class {
    /// Only used by host
    func gameStartViewDidTapLeaveButton()
    func gameStartViewDidTapDrawButton()
}

final class GameStartView: UIView {
    
    private lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End", for: .normal)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var drawDeckLabel: UILabel = {
        let label = UILabel()
        label.text = "🂠"
        label.font = .systemFont(ofSize: 128)
        return label
    }()
    
    private lazy var drawDeckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Draw", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.addTarget(self, action: #selector(drawDeckButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomPlayerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var bottomPlayerTurnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        label.text = "Your turn"
        label.isHidden = true
        return label
    }()
    
    private lazy var bottomPlayerHandLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "0"
        return label
    }()
    
    private lazy var leftPlayerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var leftPlayerTurnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        label.text = "Their turn"
        label.isHidden = true
        return label
    }()
    
    private lazy var leftPlayerHandLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "0"
        return label
    }()
    
    private lazy var topPlayerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var topPlayerTurnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        label.text = "Their turn"
        label.isHidden = true
        return label
    }()
    
    private lazy var topPlayerHandLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "0"
        return label
    }()
    
    private lazy var rightPlayerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var rightPlayerTurnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        label.text = "Their turn"
        label.isHidden = true
        return label
    }()
    
    private lazy var rightPlayerHandLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "0"
        return label
    }()
    
    private let participantType: ParticipantType
    private let hostUsername: String
    private let username: String
    private let playerTurnOrder: [String]
    private var indexOffset: Int? {
        playerTurnOrder.firstIndex(of: username)
    }
    private weak var delegate: GameStartViewDelegate?
    
    // MARK: - AnyCancellables
    
    private var drawCancellable: AnyCancellable?
    
    // MARK: - Init methods
    
    /// For hosts, the hostUsername and username fields are equivalent.
    init(as participantType: ParticipantType, hostUsername: String, username: String, playerTurnOrder: [String], delegate: GameStartViewDelegate) {
        self.participantType = participantType
        self.hostUsername = hostUsername
        self.username = username
        self.playerTurnOrder = playerTurnOrder
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(leaveButton)
        addSubview(drawDeckLabel)
        addSubview(drawDeckButton)
        addSubview(bottomPlayerLabel)
        addSubview(bottomPlayerTurnLabel)
        addSubview(bottomPlayerHandLabel)
        addSubview(leftPlayerLabel)
        addSubview(leftPlayerTurnLabel)
        addSubview(leftPlayerHandLabel)
        addSubview(topPlayerLabel)
        addSubview(topPlayerTurnLabel)
        addSubview(topPlayerHandLabel)
        addSubview(rightPlayerLabel)
        addSubview(rightPlayerTurnLabel)
        addSubview(rightPlayerHandLabel)
        
        leaveButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(12)
            make.leading.equalToSuperview().inset(16)
        }
        
        drawDeckLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
        }
        
        drawDeckButton.snp.makeConstraints { make in
            make.top.equalTo(drawDeckLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        bottomPlayerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(100)
            make.centerX.equalToSuperview()
        }
        
        bottomPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(bottomPlayerLabel.snp.centerX)
        }
        
        bottomPlayerHandLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomPlayerTurnLabel.snp.bottom).offset(4)
            make.centerX.equalTo(bottomPlayerTurnLabel.snp.centerX)
        }
        
        leftPlayerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview().offset(-80)
        }
        
        leftPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(leftPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(leftPlayerLabel.snp.centerX)
        }
        
        leftPlayerHandLabel.snp.makeConstraints { make in
            make.top.equalTo(leftPlayerTurnLabel.snp.bottom).offset(4)
            make.centerX.equalTo(leftPlayerLabel.snp.centerX)
        }
        
        topPlayerHandLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(12)
            make.centerX.equalToSuperview()
        }
        
        topPlayerLabel.snp.makeConstraints { make in
            make.top.equalTo(topPlayerHandLabel.snp.bottom).offset(4)
            make.centerX.equalTo(topPlayerHandLabel.snp.centerX)
        }
        
        topPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(topPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(topPlayerHandLabel.snp.centerX)
        }
        
        rightPlayerHandLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        
        rightPlayerLabel.snp.makeConstraints { make in
            make.top.equalTo(rightPlayerHandLabel.snp.bottom).offset(8)
            make.centerX.equalTo(rightPlayerHandLabel.snp.centerX)
        }
        
        rightPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(rightPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(rightPlayerHandLabel.snp.centerX)
        }
        
        leaveButton.isHidden = participantType == .player
        setupPlayerPositions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// In the beginning, the host is the one that draws first. Then, once the host draws,
    /// the person to the host's left (clockwise) is up to draw.
    private func setupPlayerPositions() {
        guard let indexOffset = indexOffset else {
            return
        }
        
        bottomPlayerLabel.text = playerTurnOrder[indexOffset] + " (me)"
        leftPlayerLabel.text = playerTurnOrder[(indexOffset + 1) % 4]
        topPlayerLabel.text = playerTurnOrder[(indexOffset + 2) % 4]
        rightPlayerLabel.text = playerTurnOrder[(indexOffset + 3) % 4]
        
        updateNextPlayerToDraw(hostUsername)
    }
    
    @objc
    private func leaveButtonTapped() {
        delegate?.gameStartViewDidTapLeaveButton()
    }
    
    @objc
    private func drawDeckButtonTapped() {
        delegate?.gameStartViewDidTapDrawButton()
    }
    
    func updateNextPlayerToDraw(_ nextUsername: String) {
        if nextUsername == username  {
            drawDeckButton.isHidden = false
            bottomPlayerTurnLabel.isHidden = false
            leftPlayerTurnLabel.isHidden = true
            topPlayerTurnLabel.isHidden = true
            rightPlayerTurnLabel.isHidden = true
        } else {
            drawDeckButton.isHidden = true
            bottomPlayerTurnLabel.isHidden = nextUsername != bottomPlayerLabel.text
            leftPlayerTurnLabel.isHidden = nextUsername != leftPlayerLabel.text
            topPlayerTurnLabel.isHidden = nextUsername != topPlayerLabel.text
            rightPlayerTurnLabel.isHidden = nextUsername != rightPlayerLabel.text
        }
    }
}
