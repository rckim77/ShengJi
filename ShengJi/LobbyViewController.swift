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

final class LobbyViewController: UIViewController {
    
    private lazy var roomCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var usersJoinedLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.text = "Users joined:"
        return label
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start game", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        // ENABLED FOR TESTING
//        button.isEnabled = false
        return button
    }()
    
    private let roomCode: String
    private let pusher: Pusher
    private var channel: PusherChannel?
    private var codeCancellable: AnyCancellable?
    
    init?(roomCode: String) {
        self.roomCode = roomCode
        // Pusher setup
        guard let pusherKey = AppDelegate.getAPIKeys()?.pusher else {
            return nil
        }
        let options = PusherClientOptions(host: .cluster("us2"))
        pusher = Pusher(key: pusherKey, options: options)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(roomCodeLabel)
        view.addSubview(usersJoinedLabel)
        view.addSubview(startButton)
        
        roomCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        usersJoinedLabel.snp.makeConstraints { make in
            make.top.equalTo(roomCodeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            make.centerX.equalToSuperview()
        }
        
        setupPusher()
        roomCodeLabel.text = "You are the host for room code \(roomCode)."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        pusher.disconnect()
    }
    
    private func setupPusher() {
        pusher.delegate = self
        channel = pusher.subscribe(roomCode)
        let _ = channel?.bind(eventName: "my-event", eventCallback: { event in
            if let data = event.data {
                print(data)
            }
        })
        pusher.connect()
    }
    
    @objc
    private func startButtonTapped() {

    }
}

extension LobbyViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
}
