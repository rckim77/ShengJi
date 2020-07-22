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

final class GameViewController: UIViewController {
    
    private lazy var roomLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let roomCode: String
    private let isHost: Bool
    private let pusher: Pusher
    private var channel: PusherChannel?
    
    init?(roomCode: String, isHost: Bool = false) {
        self.roomCode = roomCode
        self.isHost = isHost
        
        // Pusher config
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

        pusher.disconnect()
    }
    
    private func setupPusher() {
        pusher.delegate = self
        channel = pusher.subscribe(roomCode)
        pusher.connect()
    }
}
extension GameViewController: PusherDelegate {
    /// Used for Pusher debugging
    func debugLog(message: String) {
        print("Pusher debug: \(message)")
    }
}
