//
//  HostGameViewController.swift
//  ShengJi
//
//  Created by Ray Kim on 7/19/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import PusherSwift

final class HostGameViewController: UIViewController {
    
    private var lobbyView: HostLobbyView?
    private var gameStartView: GameStartView?
    /// Note: this does not include the 'presence-' prefix
    private let roomCode: String
    private var hostUsername: String?
    private var channel: PusherPresenceChannel?
    private var startCancellable: AnyCancellable?
    
    init(roomCode: String) {
        self.roomCode = roomCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .systemBackground
        
        setupPusher()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        appDelegate.pusher?.unsubscribe("presence-\(roomCode)")
        appDelegate.pusher?.delegate = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupPusher() {
        appDelegate.pusher?.delegate = self
        channel = appDelegate.pusher?.subscribeToPresenceChannel(channelName: "presence-\(roomCode)", onMemberAdded: { [weak self] member in
            self?.lobbyView?.addUsername(member.userId)
        }, onMemberRemoved: { [weak self] member in
            self?.lobbyView?.removeUsername(member.userId)
        })
    }
    
    private func setupLobby(username: String) {
        lobbyView = HostLobbyView(roomCode: roomCode, username: username, delegate: self)
        guard let lobbyView = lobbyView else {
            return
        }
        view.addSubview(lobbyView)
        lobbyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lobbyView.clearUsernames()
    }
    
    private func startGame() {
        gameStartView = GameStartView(as: .host, delegate: self)
        guard let gameStartView = gameStartView else {
            return
        }
        view.addSubview(gameStartView)
        gameStartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension HostGameViewController: PusherDelegate {
    func subscribedToChannel(name: String) {
        guard let username = channel?.myId else {
            return
        }
        hostUsername = username
        setupLobby(username: username)
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        let presencePrefix = "presence-"
        let startingIndex = name.index(name.startIndex, offsetBy: presencePrefix.count)
        let roomCode = name.suffix(from: startingIndex)
        let alertVC = UIAlertController(title: "Oops, that didn't work. 😦", message: "Unable to connect to room \(roomCode).", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
}

extension HostGameViewController: HostLobbyViewDelegate {
    func didDebugTap() {
        let debugVC = DebugViewController(delegate: self)
        present(debugVC, animated: true, completion: nil)
    }
    
    func didTapPairButton() {
        let pairAlert = UIAlertController(title: "Who would you like to pair?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        pairAlert.addAction(cancelAction)
        pairAlert.addTextField { textField in
            textField.placeholder = "Enter a username"
            textField.text = self.hostUsername
        }
        pairAlert.addTextField { textField in
            textField.placeholder = "Enter a username"
        }
        let pairAction = UIAlertAction(title: "Pair", style: .default) { _ in
            guard let firstUsername = pairAlert.textFields?.first?.text,
                let secondUsername = pairAlert.textFields?[1].text,
                !firstUsername.isEmpty && !secondUsername.isEmpty else {
                    print("neither text field can be empty")
                    return
            }
            print("\(firstUsername) paired with \(secondUsername)")
        }
        pairAlert.addAction(pairAction)
        present(pairAlert, animated: true, completion: nil)
    }
    
    func didTapStartButton() {
        guard let channelName = channel?.name,
            let url = URL(string: "https://fast-garden-35127.herokuapp.com/start/\(channelName)") else {
            return
        }

        lobbyView?.configure(.loading)
        
        startCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.lobbyView?.configure(.loaded)
                self?.lobbyView?.isHidden = true
                self?.startGame()
            }, receiveValue: { _ in
                print("started game and notified other users")
            })
    }
    
    func didTapLeaveButton() {
        showLeaveWarningAlert(as: .host)
    }
}

extension HostGameViewController: DebugViewControllerDelegate {
    func debugViewControllerDidAddPlayer() {
        
    }
}

extension HostGameViewController: GameStartViewDelegate {
    func gameStartViewDidTapLeaveButton() {
        showLeaveWarningAlert(as: .host)
    }
}
