//
//  PlayerGameViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/21/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import PusherSwift

final class PlayerGameViewController: UIViewController {
    
    private lazy var roomLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray
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
    private let channelName: String
    private var channel: PusherPresenceChannel?
    private let hostUsername: String
    private var playerUsername: String {
        channel?.myId ?? "unknown"
    }
    private var roomLabelText: String {
        "You're in room \(roomCode). Your username is \(playerUsername). Please wait for \(hostUsername) to begin the game."
    }
    
    init(channelName: String, hostUsername: String) {
        self.channelName = channelName
        self.hostUsername = hostUsername
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(roomLabel)
        view.addSubview(waitingLabel)
        
        roomLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        roomLabel.text = roomLabelText
        setupPusher()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.pusher?.delegate = nil
        appDelegate.pusher?.unsubscribe(channelName)
    }
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: channelName, onMemberAdded: { _ in }, onMemberRemoved: { [weak self] member in
            if member.userId == self?.hostUsername {
                print("HOST HAS LEFT")
                let hostLeftAlert = UIAlertController(title: "The host has left the room.", message: "Please try a new room.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Got it", style: .default) { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                hostLeftAlert.addAction(confirmAction)
                self?.present(hostLeftAlert, animated: true, completion: nil)
            }
        })
        
        channel?.bind(eventName: "pusher:subscription_succeeded", callback: { [weak self] members in
            self?.roomLabel.text = self?.roomLabelText
            // access to other members in room
        })
        
        channel?.bind(eventName: "start", callback: { _ in
            print("HOST HAS STARTED GAME")
        })
    }
}
extension PlayerGameViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
}
