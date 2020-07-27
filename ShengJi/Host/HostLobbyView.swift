//
//  HostLobbyView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/24/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol HostLobbyViewDelegate: class {
    func didTapLeaveButton()
    func didTapStartButton()
    func didTapPairButton()
    func didDebugTap()
}

final class HostLobbyView: UIView {
    
    enum LobbyState {
        case uninitialized, loading, loaded
    }
    
    private lazy var roomCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray
        label.text = "You are now the host. Have your friends join by sending them the code below."
        return label
    }()
    
    private lazy var roomCodeTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray
        textView.addRoundedCorners(radius: 8)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        textView.font = .preferredFont(forTextStyle: .title1)
        return textView
    }()
    
    private lazy var pairLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.text = "Your pair: Waiting to pair..."
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var usersJoinedLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.text = "Users joined:"
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var pairButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pair", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.addRoundedCorners(radius: 8)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(pairButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Leave room", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.addRoundedCorners(radius: 8)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Waiting for players...", for: .disabled)
        button.setTitle("Start game", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private var otherUsernames: [String] = [] {
        didSet {
            var text = "Players currently joined:\n\(username) (me)"
            for username in otherUsernames {
                text += "\n\(username)"
            }
            usersJoinedLabel.text = text
            startButton.isEnabled = otherUsernames.count == 1
        }
    }
    
    private var lobbyState: LobbyState = .uninitialized {
        didSet {
            var disabledCopy = ""
            
            switch lobbyState {
            case .loading:
                startButton.isEnabled = false
                disabledCopy = "Starting game..."
            case .loaded:
                startButton.isEnabled = false
                disabledCopy = "Game has started"
            case .uninitialized:
                disabledCopy = "Waiting for players..."
                startButton.setTitle("Start game", for: .normal)
            }
            
            startButton.setTitle(disabledCopy, for: .disabled)
        }
    }
    
    private let roomCode: String
    private let username: String
    private weak var delegate: HostLobbyViewDelegate?

    init(roomCode: String, username: String, delegate: HostLobbyViewDelegate) {
        self.roomCode = roomCode
        self.username = username
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(roomCodeLabel)
        addSubview(roomCodeTextView)
        addSubview(pairLabel)
        addSubview(usersJoinedLabel)
        addSubview(actionsStackView)
        actionsStackView.addArrangedSubview(pairButton)
        actionsStackView.addArrangedSubview(leaveButton)
        addSubview(startButton)
        
        let debugTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(debugTapped))
        debugTapGestureRecognizer.numberOfTapsRequired = 2
        debugTapGestureRecognizer.numberOfTouchesRequired = 2
        addGestureRecognizer(debugTapGestureRecognizer)
        
        roomCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        roomCodeTextView.snp.makeConstraints { make in
            make.top.equalTo(roomCodeLabel.snp.bottom).offset(36)
            make.centerX.equalTo(roomCodeLabel.snp.centerX)
        }
        
        pairLabel.snp.makeConstraints { make in
            make.top.equalTo(roomCodeTextView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        usersJoinedLabel.snp.makeConstraints { make in
            make.top.equalTo(pairLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        actionsStackView.snp.makeConstraints { make in
            make.bottom.equalTo(startButton.snp.top).inset(-16)
            make.centerX.equalToSuperview()
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(24)
            make.centerX.equalToSuperview()
        }
        
        roomCodeTextView.text = roomCode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addUsername(_ username: String) {
        otherUsernames.append(username)
    }
    
    func removeUsername(_ username: String) {
        otherUsernames.removeAll(where: { $0 == username })
    }
    
    func clearUsernames() {
        otherUsernames = []
    }
    
    func configure(_ state: LobbyState) {
        lobbyState = state
    }
    
    func pair(_ username: String) {
        pairLabel.text = "Your pair: \(username)"
    }
    
    @objc
    private func leaveButtonTapped() {
        delegate?.didTapLeaveButton()
    }
    
    @objc
    private func startButtonTapped() {
        delegate?.didTapStartButton()
    }
    
    @objc
    private func pairButtonTapped() {
        delegate?.didTapPairButton()
    }
    
    @objc
    private func debugTapped() {
        // TODO: For release version, do not call delegate.
        delegate?.didDebugTap()
    }
}
