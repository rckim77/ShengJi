//
//  PlayerLobbyView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/24/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import Combine

protocol PlayerLobbyViewDelegate: class {
    func playerLobbyViewDidTapLeave()
}

final class PlayerLobbyView: UIView {
    
    private lazy var roomLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.text = "Room: \(roomCode)"
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.text = "Your username: \(playerUsername)"
        return label
    }()
    
    private lazy var hostUsernameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.text = "Host: \(hostUsername)"
        return label
    }()
    
    private lazy var pairUsernameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.text = "Your pair: Waiting for host..."
        return label
    }()
    
    private lazy var waitingLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.textColor = .systemGray
        label.text = "Waiting for \(hostUsername)..."
        return label
    }()
    
    private lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Leave room", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()

    private var roomCode: String {
        let presencePrefix = "presence-"
        let startingIndex = channelName.index(channelName.startIndex, offsetBy: presencePrefix.count)
        return String(channelName.suffix(from: startingIndex))
    }
    
    private weak var delegate: PlayerLobbyViewDelegate?

    /// E.g., "presence-1884"
    private let channelName: String
    private let playerUsername: String
    private let hostUsername: String
    
    init(channelName: String, playerUsername: String, hostUsername: String, delegate: PlayerLobbyViewDelegate) {
        self.channelName = channelName
        self.playerUsername = playerUsername
        self.hostUsername = hostUsername
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(roomLabel)
        addSubview(usernameLabel)
        addSubview(hostUsernameLabel)
        addSubview(pairUsernameLabel)
        addSubview(waitingLabel)
        addSubview(leaveButton)
        
        roomLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(36)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(roomLabel.snp.bottom).offset(8)
            make.leading.equalTo(roomLabel.snp.leading)
            make.trailing.equalTo(roomLabel.snp.trailing)
        }
        
        hostUsernameLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.leading.equalTo(roomLabel.snp.leading)
            make.trailing.equalTo(roomLabel.snp.trailing)
        }
        
        pairUsernameLabel.snp.makeConstraints { make in
            make.top.equalTo(hostUsernameLabel.snp.bottom).offset(8)
            make.leading.equalTo(roomLabel.snp.leading)
            make.trailing.equalTo(roomLabel.snp.trailing)
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.bottom.equalTo(leaveButton.snp.top).inset(-16)
            make.centerX.equalToSuperview()
        }
        
        leaveButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(16)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func leaveButtonTapped() {
        delegate?.playerLobbyViewDidTapLeave()
    }
    
    func pair(_ usernames: [String]) {
        guard let pairUsername = usernames.first(where: { $0 != playerUsername }),
            usernames.contains(playerUsername) else {
            return
        }
        pairUsernameLabel.text = "Your pair: \(pairUsername)"
    }
}
