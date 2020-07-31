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
        label.font = .systemFont(ofSize: 124)
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
        return label
    }()
    
    private let participantType: ParticipantType
    private let hostUsername: String
    private let username: String
    private let playerTurnOrder: [String]
    private weak var delegate: GameStartViewDelegate?
    private var drawCancellable: AnyCancellable?
    
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
        addSubview(leftPlayerLabel)
        addSubview(leftPlayerTurnLabel)
        addSubview(topPlayerLabel)
        addSubview(topPlayerTurnLabel)
        addSubview(rightPlayerLabel)
        addSubview(rightPlayerTurnLabel)
        
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
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(96)
            make.centerX.equalToSuperview()
        }
        
        bottomPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(bottomPlayerLabel.snp.centerX)
        }
        
        leftPlayerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview().offset(-80)
        }
        
        leftPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(leftPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(leftPlayerLabel.snp.centerX)
        }
        
        topPlayerLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(72)
            make.centerX.equalToSuperview()
        }
        
        topPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(topPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(topPlayerLabel.snp.centerX)
        }
        
        rightPlayerLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview().offset(80)
        }
        
        rightPlayerTurnLabel.snp.makeConstraints { make in
            make.top.equalTo(rightPlayerLabel.snp.bottom).offset(4)
            make.centerX.equalTo(rightPlayerLabel.snp.centerX)
        }
        
        leaveButton.isHidden = participantType == .player
        setupPlayerPositions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayerPositions() {
        guard let indexOffset = playerTurnOrder.firstIndex(of: username) else {
            return
        }
        
        bottomPlayerLabel.text = playerTurnOrder[indexOffset] + " (me)"
        leftPlayerLabel.text = playerTurnOrder[(indexOffset + 1) % 4]
        topPlayerLabel.text = playerTurnOrder[(indexOffset + 2) % 4]
        rightPlayerLabel.text = playerTurnOrder[(indexOffset + 3) % 4]
    }
    
    @objc
    private func leaveButtonTapped() {
        delegate?.gameStartViewDidTapLeaveButton()
    }
    
    @objc
    private func drawDeckButtonTapped() {
        delegate?.gameStartViewDidTapDrawButton()
    }
}
