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
    /// Used by both host and players
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
    
    private lazy var bottomPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .bottom)
        return view
    }()
    
    private lazy var leftPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .left)
        return view
    }()
    
    private lazy var topPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .top)
        return view
    }()
    
    private lazy var rightPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .right)
        return view
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
        addSubview(bottomPlayerView)
        addSubview(leftPlayerView)
        addSubview(topPlayerView)
        addSubview(rightPlayerView)
        
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
        
        bottomPlayerView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(4)
            make.centerX.equalToSuperview()
        }
        
        leftPlayerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        topPlayerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8)
            make.centerX.equalToSuperview()
        }
        
        rightPlayerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
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
        
        bottomPlayerView.configure(username: playerTurnOrder[indexOffset] + " (me)")
        leftPlayerView.configure(username: playerTurnOrder[(indexOffset + 1) % 4])
        topPlayerView.configure(username: playerTurnOrder[(indexOffset + 2) % 4])
        rightPlayerView.configure(username: playerTurnOrder[(indexOffset + 3) % 4])
        
        let initialDrawEvent = DrawEvent(nextPlayerToDraw: hostUsername, playerHandCounts: [0, 0, 0, 0])
        update(initialDrawEvent)
    }
    
    @objc
    private func leaveButtonTapped() {
        delegate?.gameStartViewDidTapLeaveButton()
    }
    
    @objc
    private func drawDeckButtonTapped() {
        delegate?.gameStartViewDidTapDrawButton()
    }
    
    func update(_ drawEvent: DrawEvent) {
        let nextUsername = drawEvent.nextPlayerToDraw
        drawDeckButton.isHidden = nextUsername != username
        bottomPlayerView.hideTurnLabel(nextUsername != bottomPlayerView.username)
        leftPlayerView.hideTurnLabel(nextUsername != leftPlayerView.username)
        topPlayerView.hideTurnLabel(nextUsername != topPlayerView.username)
        rightPlayerView.hideTurnLabel(nextUsername != rightPlayerView.username)
        
        guard drawEvent.playerHandCounts.count == 4 else {
            return
        }
        
        let views = [bottomPlayerView, leftPlayerView, topPlayerView, rightPlayerView].enumerated()
        for (index, view) in views {
            view.updateHandUI(handCount: drawEvent.playerHandCounts[index])
        }
    }
}
