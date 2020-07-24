//
//  PlayerLobbyView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/24/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import Combine

final class PlayerLobbyView: UIView {
    
    private lazy var roomLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray
        label.text = "You're in room \(roomCode). Your username is \(playerUsername). Please wait for \(hostUsername) to begin the game."
        return label
    }()
    
    private lazy var waitingLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.textColor = .systemGray
        label.text = "Waiting for host..."
        return label
    }()

    private var roomCode: String {
        let presencePrefix = "presence-"
        let startingIndex = channelName.index(channelName.startIndex, offsetBy: presencePrefix.count)
        return String(channelName.suffix(from: startingIndex))
    }

    /// E.g., "presence-1884"
    private let channelName: String
    private let playerUsername: String
    private let hostUsername: String
    
    init(channelName: String, playerUsername: String, hostUsername: String) {
        self.channelName = channelName
        self.playerUsername = playerUsername
        self.hostUsername = hostUsername
        super.init(frame: .zero)
        
        addSubview(roomLabel)
        addSubview(waitingLabel)
        
        roomLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
