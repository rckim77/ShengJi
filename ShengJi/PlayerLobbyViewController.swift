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

//final class AuthRequestBuilder: AuthRequestBuilderProtocol {
//    func requestFor(socketID: String, channelName: String) -> URLRequest? {
//        var request = URLRequest(url: URL(string: "https://fast-garden-35127.herokuapp.com/builder")!)
//        request.httpMethod = "POST"
//        request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: .utf8)
//        return request
//    }
//}

final class PlayerLobbyViewController: UIViewController {
    
    private lazy var roomLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let roomCode: String
    private var channel: PusherChannel?
    
    init(roomCode: String) {
        self.roomCode = roomCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(roomLabel)
        
        roomLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        setupPusher()
        
        roomLabel.text = "You're currently in room \(roomCode). Please wait for the host to begin the game."
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
    }
}
extension PlayerLobbyViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
}
