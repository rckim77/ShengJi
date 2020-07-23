//
//  GameViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/21/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import PusherSwift

final class PlayerLobbyViewController: UIViewController {
    
    private lazy var roomLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()

    private var roomCode: String {
        let presencePrefix = "presence-"
        let startingIndex = channel.name.index(channel.name.startIndex, offsetBy: presencePrefix.count)
        return String(channel.name.suffix(from: startingIndex))
    }
    private var username: String {
        channel.me()?.userId ?? "unknown"
    }
    private let channel: PusherPresenceChannel
    
    init(channel: PusherPresenceChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(roomLabel)
        
        roomLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        setupPusher()
        
        roomLabel.text = "You're currently in room \(roomCode). Your username is \(username). Please wait for the host to begin the game."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.pusher?.delegate = nil
        appDelegate.pusher?.unsubscribe(channel.name)
    }
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
    }
}
extension PlayerLobbyViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
}
