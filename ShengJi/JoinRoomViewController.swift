//
//  JoinRoomViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/19/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import PusherSwift

final class JoinRoomViewController: UIViewController {
    
    private lazy var codeField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter code (e.g., 1234)"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.setTitleColor(.systemGray, for: .normal)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loadingVC = LoadingViewController()
    private var channel: PusherPresenceChannel?
    private var joinCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.backgroundColor = .systemBackground
        view.addSubview(codeField)
        view.addSubview(joinButton)
        
        codeField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-90)
            make.height.equalTo(48)
        }
        
        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(codeField.snp.bottom).offset(28)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.pusher?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.pusher?.delegate = nil
    }
    
    @objc
    private func joinButtonTapped() {
        guard let code = codeField.text, !code.isEmpty else {
            let invalidValuesAlert = UIAlertController(title: "Please enter a 4-digit code.", message: nil, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
            invalidValuesAlert.addAction(confirmAction)
            present(invalidValuesAlert, animated: true, completion: nil)
            return
        }
        add(loadingVC)

        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: "presence-\(code)")
    }
}

extension JoinRoomViewController: PusherDelegate {
    func subscribedToChannel(name: String) {
        loadingVC.remove()
        guard let channel = channel else {
            return
        }
        let playerLobbyVC = PlayerLobbyViewController(channel: channel)
        navigationController?.pushViewController(playerLobbyVC, animated: true)
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        loadingVC.remove()
        let presencePrefix = "presence-"
        let startingIndex = name.index(name.startIndex, offsetBy: presencePrefix.count)
        let roomCode = name.suffix(from: startingIndex)
        let alertVC = UIAlertController(title: "Oops, that didn't work. 😦", message: "Unable to connect to room \(roomCode).", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
}
