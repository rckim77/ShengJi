//
//  GameStartView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/24/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol GameStartViewDelegate: class {
    func gameStartViewDidTapLeaveButton()
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
    
    private lazy var leftPlayerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var topPlayerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var rightPlayerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    private let participantType: ParticipantType
    private let hostUsername: String
    private let username: String
    private let pairs: [[String]]
    private weak var delegate: GameStartViewDelegate?
    
    /// For hosts, the hostUsername and username fields are equivalent.
    init(as participantType: ParticipantType, hostUsername: String, username: String, pairs: [[String]], delegate: GameStartViewDelegate) {
        self.participantType = participantType
        self.hostUsername = hostUsername
        self.username = username
        self.pairs = pairs
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(leaveButton)
        addSubview(drawDeckLabel)
        addSubview(drawDeckButton)
        addSubview(bottomPlayerLabel)
        addSubview(leftPlayerLabel)
        addSubview(topPlayerLabel)
        addSubview(rightPlayerLabel)
        
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
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(92)
            make.centerX.equalToSuperview()
        }
        
        leftPlayerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview().offset(-80)
        }
        
        topPlayerLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(72)
            make.centerX.equalToSuperview()
        }
        
        rightPlayerLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview().offset(80)
        }
        
        leaveButton.isHidden = participantType == .player
        setupPlayerPositions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Use the host as the point of reference.
    private func setupPlayerPositions() {
        guard let hostPair = pairs.first(where: { $0[0] == hostUsername || $0[1] == hostUsername }),
            let hostIndex = hostPair.firstIndex(of: hostUsername),
            let hostPairIndex = hostPair.firstIndex(where: { $0 != hostUsername }),
            let playerPair = pairs.first(where: { $0[0] != hostUsername && $0[1] != hostUsername }) else {
                return
        }

        let absolutePlayerPositions = [hostPair[hostIndex], playerPair[0], hostPair[hostPairIndex], playerPair[1]]
        
        guard let indexOffset = absolutePlayerPositions.firstIndex(of: username) else {
            return
        }
        
        bottomPlayerLabel.text = absolutePlayerPositions[indexOffset] + " (me)"
        leftPlayerLabel.text = absolutePlayerPositions[(indexOffset + 1) % 4]
        topPlayerLabel.text = absolutePlayerPositions[(indexOffset + 2) % 4]
        rightPlayerLabel.text = absolutePlayerPositions[(indexOffset + 3) % 4]
    }
    
    @objc
    private func leaveButtonTapped() {
        self.delegate?.gameStartViewDidTapLeaveButton()
    }
    
    @objc
    private func drawDeckButtonTapped() {
        
    }
}
