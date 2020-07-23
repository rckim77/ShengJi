//
//  LobbyViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/19/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import PusherSwift

final class HostLobbyViewController: UIViewController {
    
    private lazy var roomCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var roomCodeTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray
        textView.addRoundedCorners(radius: 8)
        textView.font = .preferredFont(forTextStyle: .title1)
        return textView
    }()
    
    private lazy var usersJoinedLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.text = "Users joined:"
        label.textColor = .systemGray
        return label
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
    
    private let roomCode: String
    private var channel: PusherChannel?
    private var users = [String]()
    private var usersJoinedText: String {
        var text = "Users joined:"
        for user in users {
            text += "\n \(user)"
        }
        return text
    }
    private var codeCancellable: AnyCancellable?
    
    init(roomCode: String) {
        self.roomCode = roomCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(roomCodeLabel)
        view.addSubview(roomCodeTextView)
        view.addSubview(usersJoinedLabel)
        view.addSubview(startButton)
        
        roomCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        roomCodeTextView.snp.makeConstraints { make in
            make.top.equalTo(roomCodeLabel.snp.bottom).offset(16)
            make.centerX.equalTo(roomCodeLabel.snp.centerX)
        }
        
        usersJoinedLabel.snp.makeConstraints { make in
            make.top.equalTo(roomCodeTextView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            make.centerX.equalToSuperview()
        }
        
        setupPusher()
        roomCodeLabel.text = "You are now the host. Have your friends join by sending them the code below."
        roomCodeTextView.text = roomCode
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        appDelegate.pusher?.disconnect()
        appDelegate.pusher?.unsubscribe(roomCode)
        appDelegate.pusher?.delegate = nil
    }
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
        channel = appDelegate.pusher?.subscribe(roomCode)
        appDelegate.pusher?.connect()
        let _ = channel?.bind(eventName: "user-join", eventCallback: { event in
            guard let data = event.data?.data(using: .utf8),
                let json = try? JSONDecoder().decode(JoinEvent.self, from: data) else {
                    print("join event json ERROR")
                    return
            }
            print("user join event json: \(json)")
            self.users.append(json.username)
            self.usersJoinedLabel.text = self.usersJoinedText
            self.startButton.isEnabled = self.users.count == 3
        })
    }
    
    @objc
    private func startButtonTapped() {

    }
}

extension HostLobbyViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print(message)
    }
}
